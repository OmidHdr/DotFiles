# Neovim Backend IDE

A focused Neovim configuration for Java 21, Maven, Spring Boot, REST/PostgreSQL,
Docker, YAML/JSON, and Git. Java is owned exclusively by `nvim-jdtls`; do not add
`jdtls` to `lspconfig`.

## Prerequisites (Arch Linux)

Use Neovim **0.10.4 or newer** (0.11 recommended). Install system tools yourself:

```sh
sudo pacman -Syu neovim git curl unzip tar gzip ripgrep fd make gcc nodejs npm \
  jdk21-openjdk maven fish lazygit
sudo archlinux-java set java-21-openjdk
```

For Docker tooling, add `docker docker-compose`. A Nerd Font is optional but
recommended (for example `ttf-iosevka-nerd` or `ttf-meslo-nerd`) and must be
selected in the terminal emulator, not Neovim.

Verify:

```sh
nvim --version
java -version
javac -version
echo $JAVA_HOME
mvn -version
```

In fish, if `archlinux-java` does not set the environment:

```fish
set -Ux JAVA_HOME /usr/lib/jvm/java-21-openjdk
fish_add_path $JAVA_HOME/bin
```

On Debian/Ubuntu-style layouts, `/usr/lib/jvm/java-21-openjdk-amd64` is also
auto-detected. The configuration never modifies shell startup files.

## First launch

Back up an existing configuration before replacing it:

```sh
mv ~/.config/nvim ~/.config/nvim-BKUP
mkdir -p ~/.config/nvim
```

To restore it later:

```sh
mv ~/.config/nvim ~/.config/nvim-new
mv ~/.config/nvim-BKUP ~/.config/nvim
```

From this configuration directory run:

```sh
nvim --headless "+Lazy! sync" +qa
nvim --headless "+checkhealth" +qa
```

Then open Neovim, run `:MasonToolsInstall`, wait for installations, and check
`:Mason`. Mason installs:

- `jdtls`, `java-debug-adapter`, `java-test`
- `lua-language-server`, `json-lsp`, `yaml-language-server`, `lemminx`
- `bash-language-server`, Docker and Compose language servers
- `stylua`, `prettierd`, `shfmt`, `shellcheck`, `checkstyle`, `sql-formatter`

`xmlformat` is optional and may be installed separately (`python-xmlformatter`
in the AUR); XML still has LSP support when it is absent.

Update plugins with `:Lazy update`, Mason tools with `:MasonToolsUpdate`, and
Treesitter parsers with `:TSUpdate`.

## Open and use a Spring Boot project

```sh
cd /path/to/project
nvim .
```

The root is detected from `mvnw`, `pom.xml`, `gradlew`, `build.gradle`, or
`.git`. Each absolute project root gets a separate hashed JDTLS workspace under
Neovim's cache directory. Open a Java file and check `:LspInfo`; there should be
one JDTLS client. Sources are downloaded through Maven/JDTLS.

Run normally with `<leader>mr` or `:SpringBootRun`. It uses executable `./mvnw`
when present and otherwise `mvn spring-boot:run`. Logs remain in a ToggleTerm
window; press `Ctrl-C` there to stop, and `Ctrl-\` to toggle the terminal.

Run Maven commands with `:MavenTest`, `:MavenCleanTest`, `:MavenPackage`,
`:MavenVerify`, `:MavenSpotless`, and `:MavenFlyway`. Spotless/Flyway commands
require the corresponding Maven plugin in the project.

## Debug Spring Boot

1. Open a Java file and wait for JDTLS import/build to finish.
2. Confirm `java-debug-adapter` and `java-test` are installed in `:Mason`.
3. Press `<leader>jb` or run `:SpringBootDebug`.
4. Select the class containing the Spring Boot `main` method.
5. Toggle a breakpoint with `<leader>db`, then continue with `<leader>dc`.

The Java adapter detects main classes and `nvim-jdtls` generates DAP
configurations. The DAP UI opens for launch/attach and closes at termination.
Scopes, variables, call stacks, breakpoints, REPL, and console are visible.
Use `<leader>dB` for a conditional breakpoint.

Use `<leader>jn` / `<leader>jt` to run the nearest JUnit method/class and
`<leader>jd` / `<leader>jD` to debug them. `<leader>mt` runs the full Maven test
suite with output in a terminal.

## Environment and Spring profiles

An optional project-local `.env` may contain:

```dotenv
SPRING_PROFILES_ACTIVE=dev
DB_URL=jdbc:postgresql://localhost:5432/app
DB_USERNAME=app
DB_PASSWORD=change-me
JWT_SECRET=change-me
JWT_EXPIRATION=3600
```

Add `.env` to the project's `.gitignore`. Maven terminal commands load simple
`KEY=VALUE` entries without executing or printing the file. Values are passed
only to that terminal process. Debug configurations inherit Neovim's
environment; start Neovim from a shell populated by a secret manager, or edit a
selected DAP configuration at runtime and set its `env` table. Never put secrets
in this repository. Java debug launches intentionally do not silently read
`.env`.

## Formatting and diagnostics

Java formatting uses JDTLS only. Lua uses Stylua; YAML, JSON, and Markdown use
Prettierd; shell uses shfmt; SQL uses sql-formatter; XML uses optional
xmlformat. `<leader>lf` formats manually. `:FormatDisable` disables format on
save globally, `:FormatDisable!` for the current buffer, and `:FormatEnable`
re-enables it. Diagnostics use signs, underlines, conservative virtual text,
`[d`/`]d`, and `<leader>xx` for Trouble.

## Troubleshooting

### JDTLS does not start

- Require Neovim 0.10.4+, open a `.java` file, then inspect `:LspInfo`,
  `:JdtShowLogs`, and `:messages`.
- Confirm `pom.xml`/`mvnw` is above the file and `:Mason` shows JDTLS installed.
- Confirm Java 21 with `JAVA_HOME/bin/java -version`.
- Run `<leader>ju` after changing `pom.xml`.
- If a workspace is corrupt, close Neovim and remove only that project's
  directory under `~/.cache/nvim/jdtls-workspace/`.

### Java debug adapter or tests are unavailable

Run `:MasonToolsInstall`, then restart Neovim. The config resolves bundles from:

```text
~/.local/share/nvim/mason/packages/java-debug-adapter/extension/server/
~/.local/share/nvim/mason/packages/java-test/extension/server/
```

Check those paths and `:messages`. Debug setup is deliberately skipped with a
notification if the adapter JAR is missing.

### No main-class configurations

Wait until Maven import finishes, compile with `<leader>jC`, and ensure the class
has a valid `public static void main(String[] args)`. Run `<leader>ju`, then
reopen the Java buffer. Generated configurations appear only after JDTLS and the
debug bundle are ready.

### JAVA_HOME or Mason paths

The config prefers a Java-21 `JAVA_HOME`, then
`/usr/lib/jvm/java-21-openjdk`, then
`/usr/lib/jvm/java-21-openjdk-amd64`. A JAVA_HOME pointing to Java 8 is ignored.
Mason normally lives at `vim.fn.stdpath("data") .. "/mason"`; inspect the exact
value with `:lua print(vim.fn.stdpath("data"))`.

See [CHEATSHEET.md](CHEATSHEET.md) for the compact key reference.
