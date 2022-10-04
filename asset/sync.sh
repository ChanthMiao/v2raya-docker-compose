#!/bin/env bash
set -e

SCRIPT="$(readlink -f "${BASH_SOURCE[0]}")"
CURDIR="$(dirname "${SCRIPT}")"
geositeURL="https://download.fastgit.org/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"
geoipURL="https://download.fastgit.org/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"

download()
{
  url="${1}"
  tmpdir="${2}"
  # Get file name.
  file="$(awk -F'/' '{print $NF}' <<< "${url}")"
  # Download sha256sum.
  wget -t 3 -q --show-progress --progress=dot \
    -O "${tmpdir}/${file}.sha256sum" \
    "${url}.sha256sum"
  # Download file.
  wget -t 3 -q --show-progress --progress=dot \
    -O "${tmpdir}/${file}" \
    "${url}"
  pushd "${tmpdir}" || return
  # check file
  sha256sum -c "${file}.sha256sum" || rm -f "${file}"
  popd || return
}

update()
{
  fname="${1}"
  [ -f "${fname}" ] && cp -a "${fname}" "${CURDIR}/"
}

cleanup()
{
  rm -rf tmp*
}

main()
{
  trap cleanup SIGHUP SIGINT SIGQUIT SIGABRT
  # create tmp directory
  tmpdir="$(mktemp -d -p "${CURDIR}")"
  download "${geositeURL}" "${tmpdir}"
  download "${geoipURL}" "${tmpdir}"
  update "${tmpdir}/geosite.dat"
  update "${tmpdir}/geoip.dat"
  cleanup
}

main
