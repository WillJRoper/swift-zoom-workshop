# Workshop data

The workshop needs one large file that is not kept in Git:

- `zoom_ics.hdf5`: the DMO zoom initial conditions used by SWIFT.

It will be provided before the workshop. You can also generate it in notebook
1. The TESSERA region points and transfer table used to make it are included:

- `tessera_P00000_R0000_region_points.txt`
- `tessera_P00000_R0000_selection.json`
- `tessera_P00000_camb_transfer.dat`

The IC is excluded from Git. Record its checksum before distributing it:

```bash
shasum -a 256 data/zoom_ics.hdf5
```

The source region is TESSERA zoom `P00000/R0000` on COSMA. Its selection
metadata records the original paths and region properties.
