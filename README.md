## What

This repository shows examples of how to use the [cloud native buildpack framework](https://buildpacks.io/docs/) to automatically build and publish Docker images for applications.
CN buildpacks represent the evolution of Heroku and Pivotal Cloud Foundry buildpacks into a public, cross platform build tool serving the modern major language ecosystems.
With a [Dockerhub style registry](https://registry.buildpacks.io/) and [deep customization](https://buildpacks.io/docs/operator-guide/) of the build stack possible, Dockerizing applications has never been easier.

Here we have a sample Java app, just a simple Spring Boot "hello world" API, built from the provided source of the [Spring Boot Demo Workshop](https://github.com/spring-guides/gs-spring-boot).
Starting the app with `docker run -d -p 8080:8080 altorosdev/cn-buildpacks-example` and calling `GET http://localhost:8080/` will return `Greetings from Spring Boot!`.
The magic isn't the app, it's building and publishing it as a Docker image with a single command.

### Branches

This repository has three branches, each showing a different approach to working with CN buildpacks:
- `dev-owned`: the application and buildpack logic live in the same repository, and the developers are responsible for choosing the pack and ensuring the build succeeds. This approach uses less infrastructure and may be faster to set up, but leaks operations resonsibilities into development teams.
- `ops-owned`: the application and buildpack logic are cleanly separated. Application artifacts, such as jar files, are published to an internal registry, simulated here by an `artifacts` folder. The operations team owns the entirety of the buildpack process. This requires an additional component, but cleanly separates responsibilities and ensures images are standardized.
- `ci-examples`: this branch has examples and templates for using buildpacks on CI platforms other than github.

Both the dev and ops focused branches have a fully functional github CI pipeline, which publishes a Docker image containing the app to [Dockerhub](). Note that the `setup-pack` action is [officially supported](https://github.com/buildpacks/github-actions#setup-pack-cli-action).

## Why

Do your developers hate - or aren't able - to write Dockerfiles?
Would it thrill your operations team to only need to manage and release a single kind of deliverable?
Does your security team grouse that images are sorely out of date?
Buildpacks offer a way to ensure that images of a particular type (JVM, node, etc.) get built the same way, from the same base image, every time, without writing a single Dockerfile.
Increasing the level of abstraction in the CICD process to make a Docker image the basic functional unit makes the process simpler and easier to manage.

### Pros
- Clear separation of development and operations concerns
- Reduce or eliminate need to write custom dockerfiles
- Improve frequency of security updates to underlying components or dependencies
- Infrastructure and tooling agnostic
- Standardizes and automates images as the deliverable

### Cons
- Introduction of additional external dependencies
- Potential loss of build idempotency, if not mananging buildpacks internally
- Potential increase of clock time for builds
- Requires more complex CI infrastructure and process

## How

At the most basic, building and publishing a Docker image for your application is easy:
- Install Docker and log in
- Install [the `pack` CLI tool](https://buildpacks.io/docs/tools/pack/) 
- From the root of your repository, run `pack build DockerUser/MyImage --builder paketobuildpacks/builder:full --publish`

That's it!
You should see a new image pushed to your Dockerhub account.
If you run it, you'll have a containerized version of your app ready to go.
But what's actually happening?

### Framework Components
- [Buildpacks](https://buildpacks.io/docs/concepts/components/buildpack/): the fundamental unit of work. This is what performs the operations of building and packaging of source code or artifacts into a Docker image.
- [Stacks](https://buildpacks.io/docs/concepts/components/stack/): the underlying environment. This is what defines the exectuion environment for the buildpack, and the base image for the final result.
- [Builders](https://buildpacks.io/docs/concepts/components/builder/): the combination of one or more builders and stacks. This is where the framework configuration and processing definition live.

### Key Features
- A buildpack can automatically detect if it applies to the source; for example, a Maven buildpack will look for a pom.xml or built jar file. If the detection fails, the pack won't run. This means that running an invalid buildpack against a repository can be treated as a no-op.
- A single builder can contain multiple stacks and buildpacks. It also can be configured with a particular order of operations for applying buildpacks. This means a single builder can service all types of deliverables for an entire organization, and that all the deliverables can be based on the same underlying image.
- All three components are themselves Docker images. This means that the operations team can manage and serve both the build infrastructure and production deliverables with the same process.
- All three components offer highly granular configuration options. This means that individual layers of the resulting images can be individually specified and managed.
- The framework is not coupled to any particular type of infrastructure, other than images (it is both Docker and OCI compliant). This means both it and the output images are infrastructure agnostic.

Sound complicated? 
It can be, given the depth of the framework. 
But because cloud native buildpacks represent a high level of abstraction, complexity isn't a requirement.
For those who want an easy, off the shelf solution, [paketo.io](https://paketo.io) maintains a set of buildpacks and builders for public use, covering the major ecosystems.
Because the framework components are themselves images, this means adoption can be as easy as a single extra line of CI code.

### Examples and Use Cases
- This repository, which uses the [officially supported github actions](https://github.com/buildpacks/pack). 
- The [official gitlab cloud native buildpack CI plugin](https://docs.gitlab.com/ee/topics/autodevops/stages.html#auto-build-using-cloud-native-buildpacks-beta).
- [Heroku](https://devcenter.heroku.com/articles/buildpacks), [Pivotal Cloud Foundry](https://docs.cloudfoundry.org/buildpacks/), and [Tanzu VMs](https://docs.pivotal.io/application-service/2-10/buildpacks/index.html) support the original "PCF buildpacks" concept. This is the parent of the cloud native buildpacks framework, but sadly the two are not compatible, though [Heroku buildpacks have a conversion utility](https://github.com/heroku/cnb-shim).
- VMware's [Tanzu cloud platform](https://docs.pivotal.io/tanzu-buildpacks/) boasts first party integration with cloud native buildpacks, including the Paketo builders.
- Spring Boot offers cloud native buildpacks [as a first party feature](https://spring.io/blog/2020/08/14/creating-efficient-docker-images-with-spring-boot-2-3) since version 2.3, configurable directly in the pom.xml. This offers a great deal of convenience, for the tradeoff of losing the clean separation of development and operations concerns.
- Google Cloud Provider offers the comparable functionality, though as a separate product, called [Jib](https://cloud.google.com/java/getting-started/jib). A great choice for those committed to the GCP ecosystem, but at the cost of vendor lock and, at the moment, only working for JVM applications.

## References
- https://buildpacks.io/
- https://paketo.io/docs/
- https://tanzu.vmware.com/developer/guides/containers/cnb-gs-kpack/
- https://docs.pivotal.io/build-service/1-0/managing-builders.html
- https://tanzu.vmware.com/content/blog/getting-started-with-vmware-tanzu-build-service-1-0
- https://tanzu.vmware.com/developer/guides/ci-cd/tekton-gs-p2/
- https://github.com/GoogleContainerTools/jib 
- https://spring.io/blog/2020/08/14/creating-efficient-docker-images-with-spring-boot-2-3 
- https://github.com/buildpacks/pack
- https://github.com/paketo-buildpacks/samples
- https://github.com/spring-guides/gs-spring-boot
- https://devcenter.heroku.com/articles/buildpacks
- https://docs.cloudfoundry.org/buildpacks/
- https://docs.pivotal.io/application-service/2-10/buildpacks/index.html
- https://docs.gitlab.com/ee/topics/autodevops/stages.html#auto-build-using-cloud-native-buildpacks-beta
- https://github.com/heroku/cnb-shim
