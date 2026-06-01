refs:  
https://helm.sh/docs/chart_template_guide/function_list/#string-functions

commands:  
`helm diff revision myapi-release 1 3`
`k get secret sh.helm.release.v1.myapi-release.v1 -o json |jq -r '.data.release' | base64 -d | base64 -d| gunzip -c| jq`  
` k get secret sh.helm.release.v1.myapi-release.v1 -o json |jq -r '.data.release' | base64 -d | base64 -d| gunzip -c|jq '.chart.values'`
