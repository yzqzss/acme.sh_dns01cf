#!/usr/bin/env sh
# shellcheck disable=SC2034
dns_dns01cf_info='DNS01CF API
 A dns01cf DNS API Client
Site: https://github.com/HackThisSite/dns01cf/
Docs: https://github.com/HackThisSite/dns01cf/issues
Options:
 DNS01CF_URL API URL (e.g. https://example.com/)
 DNS01CF_Token JWT Domain Token
Author: yzqzss <yzqzss@yandex.com>
'

########  Public functions #####################

dns_dns01cf_add() {
  fulldomain=$1
  txtvalue=$2
  _info "Using dns01cf"
  _debug fulldomain "$fulldomain"
  _debug txtvalue "$txtvalue"
  action="set_record"

  if ! _dns01cf_request "$fulldomain" "$txtvalue" "$action"; then
    return 1
  fi
}

#Usage: fulldomain txtvalue
#Remove the txt record after validation.
dns_dns01cf_rm() {
  fulldomain=$1
  txtvalue=$2
  _info "Using dns01cf"
  _debug fulldomain "$fulldomain"
  _debug txtvalue "$txtvalue"
  action="delete_record"

  if ! _dns01cf_request "$fulldomain" "$txtvalue" "$action"; then
    return 1
  fi

  return 0
}

####################  Private functions below ##################################

_dns01cf_request() {
  fulldomain=$1
  txtvalue=$2
  action=$3


  DNS01CF_URL="${DNS01CF_URL:-$(_readaccountconf_mutable DNS01CF_URL)}"
  DNS01CF_Token="${DNS01CF_Token:-$(_readaccountconf_mutable DNS01CF_Token)}"
  if [ -z "$DNS01CF_URL" ] || [ -z "$DNS01CF_Token" ]; then
    _err "You must export variables: DNS01CF_URL and DNS01CF_Token"
    return 1
  fi

  # Remove the last '/' in the URL
  _debug "DNS01CF_URL: $DNS01CF_URL"
  if _endswith "$DNS01CF_URL" "/"; then
    DNS01CF_URL="${DNS01CF_URL%/}"
    _debug "Normalized DNS01CF_URL: $DNS01CF_URL"
  fi

  # Now save the credentials.
  _savedomainconf DNS01CF_URL "$DNS01CF_URL"
  _savedomainconf DNS01CF_Token "$DNS01CF_Token"

  export _H1="Authorization: Bearer $DNS01CF_Token"
  data="{\"fqdn\": \"$fulldomain\", \"value\": \"$txtvalue\"}"
  _debug data "$data"

  # body  url [needbase64] [POST|PUT|DELETE] [ContentType]
  response="$(_post "$data" "${DNS01CF_URL}/dns01cf/${action}" "" "POST" "application/json")"
  _debug2 response1 "$response"
  response="$(_post "$data" "${DNS01CF_URL}/dns01cf/${action}" "" "POST" "application/json")"
  _debug2 response2 "$response"

  if _contains "$response" "\"ok\"" && _contains "$response" "\"$txtvalue\""; then
    _info "action ${action} success"
    return 0
  fi

  if [ "$action" = "set_record" ] && _contains "$response" "record already exists"; then
      _info "Already exists, OK"
      return 0
  fi

  if [ "$action" = "delete_record" ] && _contains "$response" "Cannot find TXT record matching"; then
      _info "Already removed, OK"
      return 0
  fi

  _err "Failed to perform ${action} action, response: $response"
  return 1
}