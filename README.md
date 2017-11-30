# waitfor-consul

A container to wait on a consul instance and optionally a value.
Intended as an init container in Kubernetes.

## Inputs

CONSUL_HTTP_ADDR The instance address. Required.
CONSUL_HTTP_TOKEN The access token. Optional.
CONSUL_KEY Key to wait for. Optional.
EXPORT_KEY Boolean to determine whether or not to write value to filesystem. Optional.

## Notes

EXPORT_KEY if true will write out the value of CONSUL_KEY to /pod-data/consul/${CONSUL_KEY}.
This is intended to allow sharing of values with other containers in the pod via a VolumeMount (/pod-data/consul).

## End
