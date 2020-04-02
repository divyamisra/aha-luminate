aha-luminate
============

The framework used on American Heart Association's Luminate Online web properties.

Using Grunt
-----------

Before getting started using Grunt, you'll need to install [Node.js](https://nodejs.org) v12.x. (If you need to use multiple versions of Node on your machine, 
consider using [nvm](https://github.com/creationix/nvm)).

Once you have Node installed, you'll need to install the project dependencies:

```
npm install
```

If you are on a Mac and do not have root administrator permissions, you may need to use sudo:

```
sudo npm install --unsafe-perm
```

With the dependencies installed, you can run the default dev tasks:

```
grunt
```

The dev task will connect to a web server at http://localhost:8000, and run a watch task in the background until you exit.

Generally, you should not need to run the build task locally, as this is run for you by Deploybot whenever you commit a change. If for any reason you do 
need to rebuild the entire codebase, however, you can:

```
grunt build
```

Note that because the build task involves things like minifying many large image files, it may take a long time to complete, especially on Windows. Only 
run the build task if you're sure you need to.

Debug Mode
----------

By default, Luminate Online will load the minified versions of assets such as stylesheets and JavaScript files. To force a page to load unminified assets, 
set the debug session variable to "true" using the s_debug GET parameter:

```
&s_debug=true
```

Note that the minified versions of assets have a timestamp appended to their filename for cache-busting, however, the unminified versions do not. When in 
debug mode, you may need to do a hard refresh after making a change to ensure your browser has the most up-to-date version of the file.

Developing Locally
------------------

When developing locally, you can use an HTTP proxy tool to reroute requests to the aha-luminate directory on the Luminate Online filesystem to your 
machine. One simple tool available for both Windows and Mac is [Fiddler for Chrome](https://chrome.google.com/webstore/detail/fiddler/hkknfnifmbannmgkdliadghepbneplka?hl=en). With the Fiddler extension, you can add Auto Response rules to replace the String 
"http://heartdev.convio.net/aha-luminate/" with the Path "http://localhost:8000/", and "https://secure3.convio.net/heartdev/aha-luminate/" with 
"http://localhost:8000/".

You should always use debug mode when developing locally.
