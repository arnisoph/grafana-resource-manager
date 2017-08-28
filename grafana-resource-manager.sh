#!/bin/bash -e

resource=${1?}
subcmd=${2?}
curl_extra_opts=""

if [[ -z ${auth_user} ]]; then
  echo -e "Please provide admin username:"
  read -p '=> ' auth_user
fi

if [[ -z ${auth_pwd} ]]; then
  echo -e "Please provide admin pwd:"
  read -s -p '=> ' auth_pwd
fi

if [[ ${debug} == "true" ]]; then
  set -x
  curl_extra_opts+="--verbose "
fi

if [[ ${insecure} == "true" ]]; then
  curl_extra_opts+="--insecure "
fi

_curl() {
  curl \
    -fsS \
    -u "${auth_user?}:${auth_pwd?}" \
    --header "Content-Type: application/json" \
    ${curl_extra_opts?} \
    $@
}

case ${resource?} in
datasource)
  IFS=" "
  datasources=( ${datasources?} )
  unset IFS

  case ${subcmd?} in
  import)
    for datasource in ${datasources[@]}; do
      echo "Executing ${subcmd?} on datasource ${datasource?}.."
      _curl \
        -X POST \
        -d @${config_dir?}/datasources/${datasource?}.json \
        ${grafana_url?}/api/datasources \
      || exit 1
    done
    echo
  ;;
  *)
    echo "Dunno subcmd ${subcmd?}.."
    exit 1
  ;;
  esac
;;
dashboard)
  IFS=" "
  dashboards=( ${dashboards?} )
  unset IFS

  case ${subcmd?} in
  export)
    for dashboard in ${dashboards[@]}; do
      echo "Executing ${subcmd?} on dashboard ${dashboard?}.."

      _curl \
        ${grafana_url?}/api/dashboards/db/${dashboard?} \
      | jq --indent 2 '.dashboard.id=null' \
      | jq --indent 2 '.overwrite=true' \
      | jq --indent 2 'del(.meta.created)' \
      | jq --indent 2 'del(.meta.createdBy)' \
      | jq --indent 2 'del(.meta.expires)' \
      | jq --indent 2 'del(.meta.updated)' \
      | jq --indent 2 'del(.meta.updatedBy)' \
        > ${config_dir?}/dashboards/${dashboard?}.json \
      || exit 1
    done
  ;;
  import)
    for dashboard in ${dashboards[@]}; do
      echo "Executing ${subcmd?} on dashboard ${dashboard?}.."

      _curl \
        -X POST \
        -d @${config_dir?}/dashboards/${dashboard?}.json \
        ${grafana_url?}/api/dashboards/db \
      || exit 1
      echo
    done
  ;;
  delete)
    for dashboard in ${dashboards[@]}; do
      echo "Executing ${subcmd?} on dashboard ${dashboard?}.."

      _curl \
        -X DELETE \
        ${grafana_url?}/api/dashboards/db/${dashboard?} \
      || exit 1
    done
  ;;
  *)
    echo "Dunno subcmd ${subcmd?}.."
    exit 1
  ;;
  esac
;;
*)
  echo "Unknown resource ${resource?}.."
  exit 1
;;
esac
