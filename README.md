# Chobots Source Code Preservation Project

[Website](https://www.chobots.org) | [Discord Server](https://discord.gg/PKcdQTfhc8)

This repository is a source code preservation project for the original `.com` version of Chobots, created by Vayersoft in 2008 and abandoned in 2011.

# Aims

This project is focused on preserving the game and its source code as faithfully as possible to Chobot's original `.com` version. The goal is to improve the game's stability and ease of operation without altering its original features or behaviour. The `.com` version contained numerous bugs and exploits, and part of this project's objective is to patch these issues to ensure the game can be safely run for archival purposes.

This project does not aim to introduce new features or make modifications that did not exist in the original `.com` version. Such enhancements may be addressed by separate projects in future.

# Roadmap and Goals

Goals of this project are as follows but not limited to:

 - [x] Publish the source code
 - [x] Docker Compose setup to allow code to be easily compiled and run
 - [ ] Replicating the .com website
 - [ ] Replicating the .com blog
 - [x] Pre-population of minimal database including servers, clothes, word lists, sensible configuration
 - [ ] Upgrading ancient dependencies or implementing patches to mitigate CVEs
 - [x] Ensuring that admin RTMP calls (many) can only be made by authorised users
 - [x] Ensuring that XMLRPC calls require authentication
 - [x] Ensuring that sensitive client RTMP calls (many) such as `retriveItem` are server validated to avoid abuse
 - [ ] Produce detailed software architecture documents
 - [x] Salt and hash passwords
 - [x] Implement token-based authentication (replaces client-side password storage)
 - [x] Server-side validation of superuser commands
 - [ ] Safely enable guest accounts & patch specific guest exploits
 - [ ] Fix partner login
 - [x] Reauthenticate client server moves (including first login) via auth tokens rather than client stored password
 - [ ] Fix Cinema
 - [ ] Add database rows required to fix missions, pets, robots
 - [x] Fix login error message on duplicate login
 - [ ] [Fix chat history bar not displaying](https://github.com/Chobots/Chobots/issues/6)
 - [x] Upgrade to Flash Player 10 target

## Running the code

> [!CAUTION]
> Until our efforts progress, this source contains numerous potentially extremely dangerous vulnerabilities. Running this
> code locally, even if not published publicly, may expose you to security issues. Users run this code at their own
> risk.

### Game
1. Download and install Docker Desktop
2. Download this repository
3. `docker-compose up -d` (allow sharing if prompted, then rerun same command)
4. Navigate to http://localhost:8080 with a browser that supports Flash Player
5. Press play, register for an account
### Admin Panel
1. Navigate to http://localhost:8080/game/KavalokAdmin.swf (Requires Flash Player browser)
2. Log in with username: admin, password: admin

## Other projects

TODO

 - Wiki
 - Private server codebases
 - chobots-desktop

## Contributing

We welcome contributions from anyone that can help with the project. Before you start working on any of the issues we
recommend discussing with the community in our [Discord Server](https://discord.gg/PKcdQTfhc8) to ensure that your code/ideas are likely to be merged.

## Abandonware Disclaimer
This source code is from Chobots, originally developed by Vayersoft, which has ceased operations.

Chobots&#8482; Vayersoft LLC &copy; 2007-2011. All rights reserved.

To the best of our knowledge:
- The company has been dissolved and its assets liquidated.
- The code has not been re-licensed, re-released, or otherwise made available under an open source or public domain licence.
- No known legal successor or rights holder exists who is maintaining, enforcing, or asserting rights over this code.

This archive is provided strictly for historical, educational, and preservation purposes.  
Copyright law in various jurisdictions, including under fair dealing/fair use and relevant exemptions (e.g. Article 5 of the EU Copyright Directive; Section 107 of the US Copyright Act), recognises the right to reproduce and maintain works for archival, research, or non-commercial educational use when the original rights holder is unavailable or the work is otherwise inaccessible.

If you are a rights holder and wish to request removal, please contact someone with the Admin role on our [Discord Server](https://discord.gg/PKcdQTfhc8).

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
