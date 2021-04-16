## **Abstract**

The cloud native buildpacks framework specifies a robust process for building Docker images in a standardized, repeatable manner. A number of free, community tools make adopting it easy, and can eliminate the need to write Dockerfiles.


## **Introduction**

This repository shows examples of how to use the[ cloud native buildpack framework](https://buildpacks.io/docs/) to automatically build and publish standardized application Docker images. It represents the evolution of Heroku and Pivotal Cloud Foundry buildpacks into a public, cross platform build tool serving the modern major language ecosystems. With a[ Dockerhub style registry](https://registry.buildpacks.io/) and[ deep customization](https://buildpacks.io/docs/operator-guide/) of the build stack possible, Dockerizing applications has never been easier.

At its core, the framework is an additional abstraction on top of Docker images. Just as images increased the basic software unit from an application executable to a complete, reusable execution environment, buildpacks up the abstraction from an individually crafted image to a process that creates all the images necessary. This is the same sort of step up in process: the automated generation of many consumables from a few specifications. 

Why adopt a new tool when you very likely are already producing images for your applications? Do your developers hate - or aren't able - to write Dockerfiles? Would it thrill your operations team to only need to manage and release a single kind of deliverable? Does your security team grouse that images are sorely out of date? Buildpacks offer a way to ensure that images of a particular type (JVM, node, etc.) get built the same way, from the same base image, every time, without writing a single Dockerfile. Increasing the level of abstraction in the CICD process to make a Docker image the basic functional unit makes the process simpler and easier to manage.


## **A Demo**

Try it out! [This repository](https://github.com/Altoros/cn-buildpacks-example) is a fully functional demo, containing a "hello world" Java API, built by the[ Spring Boot Guides](https://github.com/spring-guides/gs-spring-boot), and using github actions CI to build and publish an image. Star the repo to trigger the CI pipeline, which [publishes to Dockerhub](https://hub.docker.com/repository/docker/altorosdev/cn-buildpacks-example). Start the app with `docker run -d -p 8080:8080 altorosdev/cn-buildpacks-example`, then `GET http://localhost:8080/` to see `Greetings from Spring Boot!`.


### **CI Explanation**

The github actions CI definition in [.github/workflows/workflow.yml](https://github.com/Altoros/cn-buildpacks-example/blob/master/.github/workflows/workflow.yml) has two jobs, designed to represent two styles of workflows to produce images:



*   `dev-owned`: the application and buildpack logic live in the same repository, and the developers are responsible for choosing the pack and ensuring the build succeeds. This approach uses less infrastructure and may be faster to set up, but leaks operations responsibilities into development teams. 
*   `ops-owned`: the application and buildpack logic are cleanly separated. Developers own the production of application executables, which are published to an internal registry, such as Artifactory or Nexus, which operations can run security tasks and pull from to release. This is simulated here by publishing the application jar to the  `artifacts` folder during the `dev-owned` job and consuming it in the `ops-owned` job. The operations team owns the entirety of the buildpack process. This requires an additional component, but cleanly separates responsibilities and ensures images are standardized.

Note that the `setup-pack` action is[ officially supported](https://github.com/buildpacks/github-actions#setup-pack-cli-action).


## **Why Buildpacks?**

Cloud-first, containerized applications are the new industry standard. Of course, this means images containing applications. Is it worth investing time and money in to adopting a new process and tool? Very likely. Consider some of the common problems with development teams manually writing Dockerfiles:



*   Base images and framework components can vary among teams and over time
*   Non-reproducible builds (`RUN apt-get install …` or `FROM node:latest` will yield different results over time), opening the possibility of introducing silent, and possibly breaking, third party changes
*   An operations concern - the creation of infrastructure which hosts applications - bleeds into the development realm
*   Security updates in the underlying image or framework components must be done manually, and entire images rebuilt and deployed
*   Very difficult to standardize and reuse base images; an organization must home-roll an entire process
*   Images with very few or very many layers are difficult to analyze and audit
*   Inevitable human error writing many Dockerfiles by hand

The buildpacks framework addresses all of these, by creating a standardized, automatable process. Buildpacks are to images as Helm charts are to deployments.


### **Pros**



*   Removes image maintenance from the developers and correctly places it under operations
*   Reduce or eliminate need to write custom dockerfiles
*   Improve frequency of security updates to underlying components or dependencies
*   Infrastructure and tooling agnostic
*   Standardizes and automates images as the deliverable


### **Cons**



*   Introduction of additional tools and possibly external dependencies
*   Potential loss of build idempotency, if using buildpacks with non-specific tags
*   Potential increase of clock time for builds, if appropriate caching not used
*   Cleanly putting the entire image lifecycle under operations requires intermediary storage to hold application artifacts  
*   Image layers are timestamped with a fixed, incorrect date to facilitate reproducibility


## **The Magic**

Getting started using buildpacks is incredibly easy:



*   Install Docker and log in
*   Install[ the pack CLI tool](https://buildpacks.io/docs/tools/pack/)
*   From the root of your repository, run `pack build DockerUser/MyImage --builder paketobuildpacks/builder:full --publish`

That's it! You should see a new image pushed to your Dockerhub account. If you run it, you'll have a containerized version of your app ready to go. But what's actually happening?


### **Framework Components**



*   [Buildpacks](https://buildpacks.io/docs/concepts/components/buildpack/): the fundamental unit of work. This is what performs the operations of building and packaging of source code or artifacts into a Docker image.
*   [Stacks](https://buildpacks.io/docs/concepts/components/stack/): the underlying environment. This is what defines the execution environment for the buildpack, and the base image for the final result.
*   [Builders](https://buildpacks.io/docs/concepts/components/builder/): the combination of one or more stacks and buildpacks. This is where the framework configuration and processing definition live.

Of course, you can create, configure, and publish custom components of all three types. The depth of configuration options mean that even a large enterprise with substantial process and standards requirements can leverage buildpacks successfully.


### **Key Features**



*   A buildpack can automatically detect if it applies to the source; for example, a Maven buildpack will look for a pom.xml or built jar file. If the detection fails, the pack won't run. This means that running an invalid buildpack against a repository can be treated as a no-op.
*   A single builder can contain multiple stacks and buildpacks. It also can be configured with a particular order of operations for applying buildpacks. This means a single builder can service all types of deliverables for an entire organization, and that all the deliverables can be based on the same underlying image.
*   Building an image automatically [creates a detailed BOM report](https://buildpacks.io/docs/buildpack-author-guide/create-buildpack/adding-bill-of-materials/) that specifies its metadata, buildpacks used, and the processes it will run. Combined with the robust logs produced at build time, debugging and security auditing greatly improve.
*   All three components are themselves Docker images. This means that the operations team can manage and serve both the build infrastructure and production deliverables with the same process.
*   All three components offer highly granular configuration options, and the ability to control each [layer](https://buildpacks.io/docs/reference/spec/buildpack-api/#layers) of the resulting image. Combined with robust [caching](https://buildpacks.io/docs/app-developer-guide/using-cache-image/) and [rebasing](https://buildpacks.io/docs/concepts/operations/rebase/), this means a common, customized image can be reused for multiple applications, and each layer updated in isolation as necessary.
*   The framework is not coupled to any particular type of infrastructure, other than images (it is both Docker and OCI compliant). This means both it and the output images are infrastructure agnostic.

Sound complicated? It can be, given the depth of the framework. But because cloud native buildpacks represent a high level of abstraction, complexity isn't a requirement. For those who want an easy, off the shelf solution,[ paketo.io](https://paketo.io) maintains a set of buildpacks and builders for public use, covering the major ecosystems. Because the framework components are themselves images, this means adoption can be as easy as a single extra line of CI code.


### **Examples in the Wild**



*   This repository, which uses the[ officially supported github actions](https://github.com/buildpacks/pack).
*   The[ official gitlab cloud native buildpack CI plugin](https://docs.gitlab.com/ee/topics/autodevops/stages.html#auto-build-using-cloud-native-buildpacks-beta).
*   [Heroku](https://devcenter.heroku.com/articles/buildpacks),[ Pivotal Cloud Foundry](https://docs.cloudfoundry.org/buildpacks/), and[ Tanzu VMs](https://docs.pivotal.io/application-service/2-10/buildpacks/index.html) support the original "PCF buildpacks" concept. This is the parent of the cloud native buildpacks framework, but sadly the two are not compatible, though[ Heroku buildpacks have a conversion utility](https://github.com/heroku/cnb-shim).
*   VMware's[ Tanzu cloud platform](https://docs.pivotal.io/tanzu-buildpacks/) boasts [first party integration](https://docs.pivotal.io/build-service/1-1/managing-images.html) with cloud native buildpacks, including the Paketo builders. It also offers some nice additional syntax sugar and audit tracking for working directly from source in a git repository, such as specifying tags and commits.
*   Spring Boot offers cloud native buildpacks[ as a first party feature](https://spring.io/blog/2020/08/14/creating-efficient-docker-images-with-spring-boot-2-3) since version 2.3, configurable directly in the pom.xml. This offers a great deal of convenience, for the tradeoff of losing the clean separation of development and operations concerns.
*   Google Cloud Provider offers the comparable functionality, though as a separate product, called[ Jib](https://cloud.google.com/java/getting-started/jib). A great choice for those committed to the GCP ecosystem, but at the cost of vendor lock and, at the moment, only working for JVM applications.


## **Conclusion**

Cloud native buildpacks represent a major step forward in modern software development. Adoption for the simple use cases is easy, and the benefits immediate. While large organizations will need to put effort into retooling CICD processes or writing custom builders, the long term savings in time and maintenance effort are a compelling value proposition.


## **References**



*   [https://buildpacks.io/](https://buildpacks.io/)
*   [https://paketo.io/docs/](https://paketo.io/docs/)
*   [https://tanzu.vmware.com/developer/guides/containers/cnb-gs-kpack/](https://tanzu.vmware.com/developer/guides/containers/cnb-gs-kpack/)
*   [https://docs.pivotal.io/build-service/1-0/managing-builders.html](https://docs.pivotal.io/build-service/1-0/managing-builders.html)
*   [https://tanzu.vmware.com/content/blog/getting-started-with-vmware-tanzu-build-service-1-0](https://tanzu.vmware.com/content/blog/getting-started-with-vmware-tanzu-build-service-1-0)
*   [https://tanzu.vmware.com/developer/guides/ci-cd/tekton-gs-p2/](https://tanzu.vmware.com/developer/guides/ci-cd/tekton-gs-p2/)
*   [https://github.com/GoogleContainerTools/jib](https://github.com/GoogleContainerTools/jib)
*   [https://spring.io/blog/2020/08/14/creating-efficient-docker-images-with-spring-boot-2-3](https://spring.io/blog/2020/08/14/creating-efficient-docker-images-with-spring-boot-2-3)
*   [https://github.com/buildpacks/pack](https://github.com/buildpacks/pack)
*   [https://github.com/paketo-buildpacks/samples](https://github.com/paketo-buildpacks/samples)
*   [https://github.com/spring-guides/gs-spring-boot](https://github.com/spring-guides/gs-spring-boot)
*   [https://devcenter.heroku.com/articles/buildpacks](https://devcenter.heroku.com/articles/buildpacks)
*   [https://docs.cloudfoundry.org/buildpacks/](https://docs.cloudfoundry.org/buildpacks/)
*   [https://docs.pivotal.io/application-service/2-10/buildpacks/index.html](https://docs.pivotal.io/application-service/2-10/buildpacks/index.html)
*   [https://docs.gitlab.com/ee/topics/autodevops/stages.html#auto-build-using-cloud-native-buildpacks-beta](https://docs.gitlab.com/ee/topics/autodevops/stages.html#auto-build-using-cloud-native-buildpacks-beta)
*   [https://github.com/heroku/cnb-shim](https://github.com/heroku/cnb-shim)