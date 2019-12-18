# RFirebird
Usage Firebird/Interbase databases in R (Linux)

## Install libs and packages
Examples with java 8 and Ubuntu 18.04:

```bash
sudo apt install openjdk-8-jdk default-jdk libbz2-dev liblzma-dev libfbclient2 -y
sudo update-alternatives --config java
```

```bash
sudo R CMD javareconf
```
or
```bash
sudo R CMD javareconf JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java
```

in R
```R
install.packages(c("RJDBC","rJava"))
```

Java health check in R
```R
library(rJava)
.jinit()
.jcall("java/lang/System", "S", "getProperty", "java.runtime.version")
```

Download JDBC Driver for you server version from: https://firebirdsql.org/en/jdbc-driver/
unzip, and use path to full package version (ex: jaybird-full-2.2.15.jar) as 'driver_path'

## Usage
Examples watch into example.R
