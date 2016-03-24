## Factorio headless server

So this isn't ideal, but it works. Then again, that's true with everything. The only thing I've noticed that is weird is that the first time the thing comes up, it can take a few connection attempts to connect. There's also some weird path stuff going on with the upstream binary so for whatever reason, you need to call the entire path to the binary.


#### Running the pre-built container from Docker hub

You'll need a savegame in a volume or this can create one for you. This is the way the game works, not something I chose. You also have to run it in bridge mode because of the way the p2p networking works.

Also I'm assuming you're going to want to use a volume mount, otherwise upgrading this guy is awful and requires launching more containers to copy the savegame out, etc.

Creating the savegame and launching the server:

```
$ docker run -e SEED_SERVER=true --name factorio -net bridge -p 34197:34197/udp -v /opt/factorio/saves:/opt/factorio/saves skord/factorio:0.12.28 /opt/factorio/bin/x64/factorio --start-server savegame
```

Upgrading to a new server version:

```
$ docker stop factorio && docker rm factorio
$ docker run --name factorio -net bridge -p 34197:34197/udp -v /opt/factorio/saves:/opt/factorio/saves skord/factorio:0.12.29 /opt/factorio/bin/x64/factorio --start-server savegame
```

All the above does is remove the seed argument (which would be ignored if you already had savegame.zip in your saves, you're welcome) and bumps the image version.

#### Building it on your own

There's a Rakefile that will build and publish this. Just change the string in the VERSION file to what you want it to be and run "rake tag" if you intend on just running it locally. Otherwise if you want to push it to a registry, you'll need to change my name for yours, then run rake publish.

#### Quick server task

Want to run a quick server with no persistence really quickly? Run ```rake quick_server``` for a server and then connect to the IP (localhost or whereever your docker daemon runs). You will lose all your fun game time when you Ctrl-C to quit.
