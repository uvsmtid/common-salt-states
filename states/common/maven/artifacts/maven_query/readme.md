
# Intro #

The original idea of this tool was to get access to results of Maven
command like this programatically:
```
mvn dependency:resolve
```
However, its looks impossible - see [details here][1]. And code in
`MavenQuery` class is pretty useless (it's a failed attempt) now.

Instead of Java code, a Python script was created to parse the Maven output.

# Executing with Maven #

The following steps rely on Maven to set up classpath to execute the jar.

* Use this command to compile:
  
  ```
  mvn clean install
  ```

* Use this command to run:
  
  ```
  mvn exec:java -Dexec.mainClass="com.example.MavenQuery"
  ```

# Executing without Maven #

The following steps build jar with all dependencies and avoid relying on
Maven to execute the jar.

See also [here][2].

* Build package with all dependencies:
  
  ```
  mvn assembly:assembly
  ```

* Execute jar:

  ```
  java -jar ./target/maven_query-0.0.1-SNAPSHOT-jar-with-dependencies.jar
  ```

# [footer] #

[1]: http://stackoverflow.com/q/29224974/441652
[2]: http://stackoverflow.com/a/1729094/441652

