
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

See also: http://stackoverflow.com/a/1729094/441652

* Build package with all dependencies:
  
  ```
  mvn assembly:assembly
  ```

* Execute jar:

  ```
  java -jar ./target/maven_query-0.0.1-SNAPSHOT-jar-with-dependencies.jar
  ```

