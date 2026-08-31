# Yoga Book SOF topology package

This release-only packaging installs the physically validated IPC3
`sof-cht-rt5677.tplg` topology for the Lenovo Yoga Book YB1-X91L. It is kept
separate from the upstream-facing topology commit history.

Build the topology with the normal SOF topology2 production target, then run:

```bash
make -C packaging/yogabook-topology \
  TOPOLOGY=/path/to/sof-cht-rt5677.tplg \
  OUTPUT=/path/to/artifacts test
```

The package builder accepts only the topology that passed physical speaker and
microphone validation:

```text
746962d80115e3b9b0b2fbe44673b4e3acef5f06f7914baf235a5a652e8be09c
```

Install the resulting `sof-topology-yogabook_1.0.1_all.deb` together with
`firmware-sof-signed` and `alsa-ucm-conf-yogabook`.
