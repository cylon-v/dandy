# Silicon
Silicon is a minimalistic web API framework. Its main idea is to implement an approach 
from Clean Architecture principles - "web is just a delivery mechanism". 
Silicon is build on top of IoC container Hypo and forces to use dependency injection 
approach everywhere.    

## Architecture

![Silicon Architecture](https://user-images.githubusercontent.com/4575064/34541424-2b7b6c24-f0e9-11e7-8023-abc0df48c9c4.png)

### Separation of Concerns

Model-View-Controller (MVC) now is a sign of bad taste. Everybody who built more or less serious production
web-application know that controllers become to be fat. Splitting controllers by context can a bit improve
the situation but it's a visual trick, it still looks like:

```ruby
class UserController
  def index
    # ... 
  end
  
  def show
    # ... 
  end

  def update
    # ... 
  end

  # ...  
end
```  

It roughly violates one of main OOP rules - [Single Responsibility Principle](). Somebody can say "controller is only intended
to control the process of request handling", but it's too large responsibility. Actually it's responsible for creating,
updating and deleting models, showing views, services invocation and so on. And it's an ideal picture. Usual situation is
when domain code is located in controllers.
Silicon replaces regular controllers with a chain of atomic actions. It doesn't protect you to use bad practices but
allows to easily separate \[controller-\]actions. Every action is a simple brick:

```ruby
class ShowUsers
  def call
    # ...
  end
end

class UpdateUser
  def call
    # ...
  end
end
```

A route can represent much more complicated logic containing several steps. For that purpose Silicon provides an ability
to chain actions:

```
    -> update_user -> notify_admin -> log_action
```

Every of enumerated above actions are classes respond to method "call". More details about chains construction are  
described below.
   
### Router

Silicon Router is completely new vision of how to create flexible, lightweight, language-independent DSL for designing
a schema of web-application routing. Rails, Hanami, Sinatra and others provide more or less visually similar DSL for
defining routing schema. Their routers use Ruby blocks-based DSL for that. Ruby is a power, Ruby is a weakness:
for such purpose Ruby is too verbose. An example demonstrating all features:   

```
:receive
    .->
        /auth ->
            :before -> load_current_user

            /posts ->
                GET -> list_posts
                POST -> create_post

                $id ->
                    :before -> load_post

                    GET -> show_post
                    PATCH -> update_post -> :respond =200
                    DELETE -> remove_post -> :respond =200

                    /comments ->
                        GET -> list_comments
                        POST => add_comment => notify_author =* notify_subscribers -> :respond <- comment_plain =201

                        $comment_id ->
                            GET -> show_comment -> :respond <- comment
                            DELETE -> remove_comment
:catch -> handle_errors
```  

Routes configuration by default is located in file `app.routes`. You can change it's location in `silicon.yml` file.   

#### Action path
Routes definition has tree-like structure. There're two root entries - :receive and :catch.

:receive section describes regular flow of incoming request.

:catch section defines an action which calls when an error raised somewhere in the regular flow.

:receive section should start from `.` - root point of the routing.

Every line of the definition is a piece of path to target action or chain.

Symbols `->` and `<TAB>` emulates directory structure. Configuration demonstrated above can be interpreted like:
```
    GET     /auth/posts/$id (show_post)
    DELETE  /auth/posts/$id/comments/$comment_id (remove_comment)
```
Symbol `$` allows to receive request parameters.
 
#### Action chaining
As you can see, some routes references to a chain of actions, like:

```
    -> update_user -> notify_admin -> log_action
```  
It means that you can define a number of atomic operations in order to reach request goals.

`->` is a simple sequential type of action. Process flow waits until finishing of it's execution before starting the next
action or making a response.

More interesting case:

```
    => add_comment => notify_author =* notify_subscribers
```
 
`=>` is a parallel operation. All parallel operations complete before the next sequential (`->`) or ending of the chain.

`=*` is an asynchronous operation. It must not be completed before next sequential and even ending of the chain. 

The time of execution of asynchronous and parallel operations can be limited in config file (by default it's 10 seconds). 

#### Sending Response
By default Silicon responds with HTTP status 200 (201 for POST) and empty body. You can define :respond instructions
for sending custom status and specific response body:

```
    ...
    POST => add_comment => ... -> :respond <- comment_plain =201
``` 

Expression `:respond <-` declares a view ("comment_plain") and a status `=` (201). Details about views formatting are described below.


### Dependency Injection
Dependency Injection (DI) is a heart of Silicon web-application. Every Silicon action can utilize known variables/entities 
in the application. In example:

when you have:

```
    GET /auth/posts/$id (show_post)
```

you can easily use request parameter:

```ruby
class ShowPost
  def initialize(id)
    @id = id
  end
  
  def call
    # somehow extract a post using @id
  end
end
```   

Every action returns a result that automatically registers in the container and can be used in further actions:

```
    GET     /auth/posts/$id (load_post, show_post)
```

```ruby
class ShowPost
  def initialize(load_post_result)
    @post = load_post_result
  end
  # ...
end
```  

You can customize the name of action result:

```ruby
class LoadPost
  #...
  def result_name
    'post'
  end 
end
```

and use:

```ruby
class ShowPost
  def initialize(post)
    @post = post
  end
  
  # ...
end
```

In order to support another types by DI you need to adjust the configuration `silicon.yml`:

```
path:
  dependencies:
    - actions # default location
    - services/injectable # additional dependencies location
```

#### Objects lifetime
As mentioned before, dependency injection is a heart of Silicon. And as you probably noticed we register dependencies 
for every new request. In order to avoid leaking the memory for request-specific objects Silicon uses Hypo::Scope lifetime 
style for registered objects. Every time when request is ending the dependencies remove from the container. 

BTW, using Hypo::Scope and it's `finalize` method definition you can implement 
[Unit of Work](https://martinfowler.com/eaaCatalog/unitOfWork.html) pattern. 

```ruby
class DbSession
  include Hypo::Scope
  
  def initialize
    @transaction = Transaction.new
  end

  def finalize
    # unexpected behavior handling is in :catch section implementation
    @transaction.commit      
  end
end
```

### Views
By default Silicon handles only JSON requests using [JBuilder](https://github.com/rails/jbuilder) engine. But you can extend a number of engines using
method `add_view_builder` in your `app.rb`:

```ruby
class App < Silicon::App
 def initialize
    super

    add_view_builder(MyHtmlViewBuilder, 'html')
  end
end
```

View templates are located in `views` directory; you can change default location in `silicon.yml`:
```
path:
  views: custom/views/location
```

In view template you can use any objects registered in the container. In example, you have a chain:

```
    GET /posts/$id
    -> load_user -> load_post -> load_comments -> :respond <- show_post
```

and it's implementation in Ruby:

```ruby
class LoadPost
  def initialize(id)
    @id = id
  end
    
  def call
    # Not a real ORM, just for the demo.
    # Posts.find(id)
  end
    
  def result_name
    'post'
  end
end

class LoadComments
  def initialize(id)
    @id = id
  end
    
  def call
    # Not a real ORM, just for the demo.
    # Comments.where(post: post)
  end
    
  def result_name
    # as you probably noticed this annoying action can be replaced 
    # with a convention in your own base class for application actions. 
    # Also instead of this declaration you can still use default name 
    # for actions like 'load_comments_result'.
  
    'comments'
  end
end
```

Draw the view:

```ruby
json.post do
  json.title @post.title
  # ...
  
  json.comments @comments do |comment|
    json.message comment.message
    # ...
  end
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'silicon'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install silicon
    

## Getting Started

## Development

Before making any contributions please make sure you are agree:

* 3 lines of code is better than 100 for the same functionality implementation, 0 lines is the best.
* Keep initial idea as simple as it possible. Plugins for additional functionality are more preferable. 
* Do not use comments for obvious code; if your code is not obvious then try to make it obvious - 
extract method, variable, perform more steps to make it more clear.

Usual, but always helpful steps:
 
After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.
To install this gem onto your local machine, run `bundle exec rake install`. 
To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## 


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cylon-v/silicon.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
