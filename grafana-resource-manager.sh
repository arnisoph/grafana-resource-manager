#!/bin/bash -e


resource=${1?}
subcmd=${2?}

if [[ -z ${auth_user} ]]; then
  echo -e "Please provide admin username:"
  read -p '=> ' auth_user
fi

if [[ -z ${auth_pwd} ]]; then
  echo -e "Please provide admin pwd:"
  read -s -p '=> ' auth_pwd
fi

case ${resource?} in
datasource)
  IFS=" "
  datasources=( ${datasources?} )
  unset IFS

  case ${subcmd?} in
  import)
    for datasource in ${datasources[@]}; do
      echo "Executing ${subcmd?} on datasource ${datasource?}.."

      curl \
        -X POST \
        -fsS \
        -u "${auth_user?}:${auth_pwd?}" \
        --header 'Content-Type: application/json' \
        -d @${config_dir?}/datasources/${datasource?}.json \
        ${grafana_url?}/api/datasources \
      || exit 1
    done
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

      curl \
        -fsS \
        -u "${auth_user?}:${auth_pwd?}" \
        --header 'Content-Type: application/json' \
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

      curl \
        -X POST \
        -fsS \
        -u "${auth_user?}:${auth_pwd?}" \
        --header 'Content-Type: application/json' \
        -d @${config_dir?}/dashboards/${dashboard?}.json \
        ${grafana_url?}/api/dashboards/db \
      || exit 1
    done
  ;;
  delete)
    for dashboard in ${dashboards[@]}; do
      echo "Executing ${subcmd?} on dashboard ${dashboard?}.."

      curl \
        -X DELETE \
        -fsS \
        -u "${auth_user?}:${auth_pwd?}" \
        --header 'Content-Type: application/json' \
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
