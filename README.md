# Fortaleza

This is the source code of Fortaleza, a
RPG created by [Miguel Cepero][1] from Merchise Group in the nineties. It was a
very popular game in Cuba.

You can read more about them here:
 * [Merchise Group][2].
 * [Fortaleza 1][3] (in Spanish)

## Building

There is an [open issue][6] for tracking progress trying to build this repo.

### Docker + DOSBox + Tooling

There are 2 [docker images](https://hub.docker.com/repository/docker/davidmpaz/dosbox-tp7) available for building this project, depending on the platform, use one accordingly.

Pull image: `docker pull davidmpaz/dosbox-tp7:1.1-amd64` and while being in 
the root directory of this project, start a container: 
`docker run --rm -p 8080:8080 -v $(pwd):/app/src/ davidmpaz/dosbox-tp7:1.1-amd64`.

Open your browser and point it to: http://localhost:8080

Source code will be accessible under `D:`, Turbo Pascal and Turbo Assembler 
are already included in PATH, which means they are invokable from everywhere 
inside the container (under DOS).

Each .pas and .asm file can be compiled separately or all in batch by invoking
`build.bat`. Look inside this file to get an idea on how to use **tpc** or 
**tasm** and which flags to pass.

## Running

If you want to play it, there are EXE builds available in a third party site:

  - [La Fortaleza (part I)][4]
  - [La Fortaleza (part II)][5]

take the usual precautions before running an executable downloaded from the
internet.

Copyright:
  (c) 1992 - 2013 Miguel Cepero

License:
  GPLv3+ (see COPYING for details).


 [1]: https://twitter.com/miguelcepero
 [2]: https://en.wikipedia.org/wiki/Merchise
 [3]: http://wiki.caad.es/La_fortaleza_I:_En_las_entra%C3%B1as_de_la_bestia
 [4]: https://www.caad.es/?q=node/878
 [5]: https://www.caad.es/?q=node/879
 [6]: https://github.com/merchise/fortaleza/issues/2
