# acme.sh_dns01cf


## Install

```bash
mkdir -p ~/.acme.sh/dnsapi
curl -L https://github.com/yzqzss/acme.sh_dns01cf/raw/refs/heads/main/dns_dns01cf.sh > ~/.acme.sh/dnsapi/dns_dns01cf.sh
```

## Usage

```bash
export DNS01CF_URL="https://YOUR_API_URL/"
export DNS01CF_Token="Domain Token"
acme.sh --issue --dns dns_dns01cf <...acmes options..>
```

Note, we persist the `DNS01CF_URL` and `DNS01CF_Token` into perdomain configuration instead of global account configuration.
