# Silicon

Silicon is a minimalistic web API framework. Its main idea is to implement an approach 
from Clean Architecture principles - "web is just a delivery mechanism". 
Silicon is build on top of IoC container Hypo and forces to use dependency injection 
approach everywhere.  

## Basic Concepts

1. [Dependency Injection](https://en.wikipedia.org/wiki/Dependency_injection) is a heart of Silicon. Atomic actions can depend on request parameters, services, repositories, output of other 
actions and other stuff. You can easily inject such dependencies in your actions through a constructor. 
Dependency Injection significantly improves development experience: isolate your components, enjoy writing unit tests.

```ruby
class LoadPost
  def initialize(id, post_storage)
    @id = id
    @storage = post_storage
  end
  
  def call
    @storage.find(@id)
  end
end
```     

2. Instead of boring Ruby block-style routes definition like in Rails, Sinatra and others Silicon uses its 
own language for that. Small example:

```
:receive
    .->
        :before -> load_current_user          
        /posts ->
            $id ->
                :before -> load_post
                /comments ->
                    POST -> add_comment -> notify_author -> notify_subscribers -> :respond <- comment_test =201
:catch -> handle_errors
```

3. The combination of flexible router and dependency injection breaks existing dogmas. 
Silicon framework introduces Abstract Chain pattern as a replacement for Model-View-Controller 
and other ancient approaches. Every request handles by a set of atomic actions. 

```
    # POST /posts/$id/comments
    ... -> load_post -> add_comment -> ... 
``` 

```ruby
class LoadPost
  def initialize(id, post_storage)
    @id = id
    @storage = post_storage
  end
  
  def call
    @storage.find(@id)
  end
  
  def result_name
    'post'
  end 
end

class AddComment
  def initialize(post, silicon_data, user, comment_storage)
    @post = post
    @data = silicon_data
    @user = user
    @storage = comment_storage 
  end
  
  def call
    @storage.create(post: @post, message: @data[:message], user: @user)
  end  
end
```

4. Silicon is a micro-framework for micro-services. It's not intended to create monolithic giants! 
In terms of [Domain Driven Design](https://en.wikipedia.org/wiki/Domain-driven_design) 
concepts one Silicon application should wrap only one [Bounded Context](https://en.wikipedia.org/wiki/Domain-driven_design#Bounded_context).

## Getting Started

1. Install Silicon: 

```
    $ gem install silicon
```

2. At the command prompt, create a new Silicon application:

```
    $ silicon new silicon-app
```

3. Go to directory `silicon-app` and start the application using a server you prefer:

```
    $ puma -p 8000 config.ru
```

or just

```
    $ rackup -p 8000 config.ru
```

4. Using a browser, go to http://localhost:8000 and you'll see: 

```json
  {"message": "Welcome to silicon-app!"}
```

5. Investigate example application code, it will explain most of Silicon aspects.
6. For more details visit our [Wiki](https://github.com/cylon-v/silicon/wiki).

## Development

Usual, but always helpful steps:
 
After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.
To install this gem onto your local machine, run `bundle exec rake install`. 
To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cylon-v/silicon.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
