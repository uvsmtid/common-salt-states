package com.example;

import java.io.File;
import java.util.Collections;

import org.apache.maven.shared.invoker.InvocationRequest;
import org.apache.maven.shared.invoker.DefaultInvocationRequest;
import org.apache.maven.shared.invoker.DefaultInvoker;
import org.apache.maven.shared.invoker.Invoker;
import org.apache.maven.shared.invoker.MavenInvocationException;

class MavenQuery {

    public static void main(String[] args) throws MavenInvocationException {

        InvocationRequest request = new DefaultInvocationRequest();
        request.setPomFile(
            new File(
                "/home/uvsmtid/Works/maritime-singapore.git/clearsea-distribution/pom.xml"
            )
        );
        request.setGoals(Collections.singletonList("dependency:list"));

        Invoker invoker = new DefaultInvoker();
        invoker.execute(request);
    }

}
