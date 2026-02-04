# kata-rpm-scanner
Figure which kata rpm is being shipped in a specific OCP version/range

## Usage

First ensure you have the right cluster pull secret: https://console.redhat.com/openshift/create/local (just use "download/copy pull secret)

Run the script
```
./kata-scanner.sh <start-version> <end-version>

# Example
# ./kata-scanner.sh 4.19 4.20.1
# Scans from 4.19.0 till 4.20.1
```
or
```
./kata-scanner.sh <version>

# Example
# ./kata-scanner.sh 4.18.2
# Only shows the 4.18.2 kata rpm
```

Example outputs:
```
$ ./kata-scanner.sh 4.19.19 
Fetching available versions from OpenShift mirror...
Scanning single version: 4.19.19
-----------------------------------------------------------------------
Checking 4.19.19... kata-containers-3.17.0-4.rhaos4.19.el9.x86_64.rpm

=======================================================================
RESULTS GROUPED BY RPM FILENAMES
=======================================================================
EXTENSIONS: kata-containers-3.17.0-4.rhaos4.19.el9.x86_64.rpm
VERSIONS:
  4.19.19
-----------------------------------------------------------------------


$ ./kata-scanner.sh 4.19.19 4.19.20
Fetching available versions from OpenShift mirror...
Scanning range: 4.19.19 to 4.19.20
-----------------------------------------------------------------------
Checking 4.19.19... kata-containers-3.17.0-4.rhaos4.19.el9.x86_64.rpm
Checking 4.19.20... kata-containers-3.21.0-3.rhaos4.19.el9.x86_64.rpm

=======================================================================
RESULTS GROUPED BY RPM FILENAMES
=======================================================================
EXTENSIONS: kata-containers-3.21.0-3.rhaos4.19.el9.x86_64.rpm
VERSIONS:
  4.19.20
-----------------------------------------------------------------------
EXTENSIONS: kata-containers-3.17.0-4.rhaos4.19.el9.x86_64.rpm
VERSIONS:
  4.19.19
-----------------------------------------------------------------------


```
