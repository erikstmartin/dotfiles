# Print an optspec for argparse to handle cmd's options that are independent of any subcommand.
function __fish_copilot_global_optspecs
    string join \n v/version i/interactive= fleet p/prompt= s/silent enable-memory model= reasoning-effort= context= auto-tier= enable-reasoning-summaries agent= r/resume= continue n/name= session-id= connect= cloud w/worktree= allow-all-tools allow-all-paths disallow-temp-dir banner screen-reader plain-diff C= log-dir= extension-sdk-path= config-dir= log-level= save-trajectory-output= prefer-version= stream= output-format= share= share-gist add-dir= attachment= disable-mcp-server= disable-builtin-mcps enable-all-github-mcp-tools add-github-mcp-toolset= add-github-mcp-tool= plugin-dir= additional-mcp-config= allow-all-mcp-server-instructions additional-content-exclusion-policies= allow-tool= deny-tool= available-tools= excluded-tools= secret-env-vars= allow-url= deny-url= allow-all-urls allow-all yolo max-autopilot-continues= mode= autopilot plan experimental bash-env= mouse= show-timing server ui-server headless managed-server acp stdio host= disable-remote-sessions remote remote-export port= session-idle-timeout= auth-token-env= log-interactive-shells print-debug-info collect-debug-logs= collect-debug-logs-output= relay ahp= environment-id= ahp-host listen= workspace= sandbox dynamic-retrieval= enable-mcp-server= max-ai-credits= assisted-approval embedded-host usage-output-file= no-custom-instructions no-auto-update no-ask-user no-color no-experimental no-bash-env no-mouse no-remote no-remote-export no-auto-login no-sandbox no-eager-powershell-resolution h/help
end

function __fish_copilot_needs_command
    # Figure out if the current invocation already has a command.
    set -l cmd (commandline -opc)
    set -e cmd[1]
    argparse -s (__fish_copilot_global_optspecs) -- $cmd 2>/dev/null
    or return
    if set -q argv[1]
        # Also print the command, so this can be used to figure out what it is.
        echo $argv[1]
        return 1
    end
    return 0
end

function __fish_copilot_using_subcommand
    set -l cmd (__fish_copilot_needs_command)
    test -z "$cmd"
    and return 1
    contains -- $cmd[1] $argv
end

complete -c copilot -n "__fish_copilot_needs_command" -s i -l interactive -d 'Start interactive mode and automatically execute this prompt' -r
complete -c copilot -n "__fish_copilot_needs_command" -s p -l prompt -d 'Execute a prompt in non-interactive mode (exits after completion)' -r
complete -c copilot -n "__fish_copilot_needs_command" -l model -d 'Set the AI model to use (use \'auto\' to let Copilot pick automatically)' -r -f -a "auto\t''
claude-sonnet-5\t''
claude-fable-5.1\t''
claude-fable-5\t''
claude-opus-5.5\t''
claude-opus-5\t''
claude-opus-4.8\t''
claude-opus-4.8-fast\t''
claude-opus-4.7\t''
claude-sonnet-4.6\t''
claude-haiku-4.5\t''
gpt-6-sol\t''
gpt-6-luna\t''
gpt-6-astra\t''
gpt-5.6-sol\t''
gpt-5.6-terra\t''
gpt-5.6-luna\t''
gpt-5.5\t''
gpt-5.4\t''
gpt-5.4-mini\t''
gpt-5.3-codex\t''
gpt-5-mini\t''
mai-code-1.1-flash\t''
gemini-3.8-flash\t''
gemini-3.7-flash\t''
gemini-3.6-flash\t''
gemini-3.5-flash\t''
grok-4.5\t''
kimi-k3\t''
kimi-k2.7-code\t''"
complete -c copilot -n "__fish_copilot_needs_command" -l reasoning-effort -d 'Set the reasoning effort level' -r -f -a "none\t''
minimal\t''
low\t''
medium\t''
high\t''
xhigh\t''
max\t''"
complete -c copilot -n "__fish_copilot_needs_command" -l context -d 'Set the context window tier (overrides persisted setting)' -r -f -a "default\t''
long_context\t''"
complete -c copilot -n "__fish_copilot_needs_command" -l auto-tier -d 'Set the Auto routing profile' -r -f -a "efficiency\t''
balance\t''
intelligence\t''"
complete -c copilot -n "__fish_copilot_needs_command" -l agent -d 'Specify a custom agent to use' -r
complete -c copilot -n "__fish_copilot_needs_command" -s r -l resume -d 'Resume from a previous session (optionally specify existing session ID, task ID, ID prefix, or name; name matching is exact, case-insensitive)' -r
complete -c copilot -n "__fish_copilot_needs_command" -s n -l name -d 'Set a name for the new session' -r
complete -c copilot -n "__fish_copilot_needs_command" -l session-id -d 'Resume an existing session or task by ID, or set the UUID for a new session' -r
complete -c copilot -n "__fish_copilot_needs_command" -l connect -d 'Connect directly to a remote session (optionally specify session ID or task ID)' -r
complete -c copilot -n "__fish_copilot_needs_command" -s w -l worktree -d 'Create or reuse an isolated git worktree and start the session inside it (name is optional; the location follows the worktreePathTemplate setting)' -r
complete -c copilot -n "__fish_copilot_needs_command" -s C -d 'Change working directory before doing anything else' -r
complete -c copilot -n "__fish_copilot_needs_command" -l log-dir -d 'Set log file directory (default: ~/.copilot/logs/)' -r
complete -c copilot -n "__fish_copilot_needs_command" -l extension-sdk-path -d 'Override the bundled @github/copilot-sdk injected into extension subprocesses with a local `copilot-sdk/` folder. Invalid paths fall back to the bundled SDK.' -r
complete -c copilot -n "__fish_copilot_needs_command" -l config-dir -d 'Set the configuration directory (default: ~/.copilot). Deprecated: use COPILOT_HOME env var instead.' -r
complete -c copilot -n "__fish_copilot_needs_command" -l log-level -d 'Set the log level' -r -f -a "none\t''
error\t''
warning\t''
info\t''
debug\t''
all\t''
default\t''"
complete -c copilot -n "__fish_copilot_needs_command" -l save-trajectory-output -d 'Save execution trajectory to specified file' -r
complete -c copilot -n "__fish_copilot_needs_command" -l prefer-version -d 'Load a specific cached package version (used by /downgrade)' -r
complete -c copilot -n "__fish_copilot_needs_command" -l stream -d 'Enable or disable streaming mode' -r -f -a "on\t''
off\t''"
complete -c copilot -n "__fish_copilot_needs_command" -l output-format -d 'Output format: \'text\' (default) or \'json\' (JSONL, one JSON object per line)' -r -f -a "text\t''
json\t''"
complete -c copilot -n "__fish_copilot_needs_command" -l share -d 'Share session to markdown file after completion in non-interactive mode (default: ./copilot-session-<id>.md)' -r
complete -c copilot -n "__fish_copilot_needs_command" -l add-dir -d 'Allow file access to a directory and load its .github/skills and .github/agents as trusted configuration (can be used multiple times). A relative path resolves against the session working directory (the --resume/--worktree/-C directory), whatever order the options appear in' -r
complete -c copilot -n "__fish_copilot_needs_command" -l attachment -d 'Attach a file (image or native document) to the initial prompt; only valid in non-interactive mode (can be used multiple times)' -r
complete -c copilot -n "__fish_copilot_needs_command" -l disable-mcp-server -d 'Disable a specific MCP server (can be used multiple times)' -r
complete -c copilot -n "__fish_copilot_needs_command" -l add-github-mcp-toolset -d 'Add a toolset to enable for the GitHub MCP server instead of the default CLI subset (can be used multiple times). Use "all" for all toolsets.' -r
complete -c copilot -n "__fish_copilot_needs_command" -l add-github-mcp-tool -d 'Add a tool to enable for the GitHub MCP server instead of the default CLI subset (can be used multiple times). Use "*" for all tools.' -r
complete -c copilot -n "__fish_copilot_needs_command" -l plugin-dir -d 'Load a plugin from a local directory (can be used multiple times). A relative path resolves against the session working directory (the --resume/--worktree/-C directory), whatever order the options appear in' -r
complete -c copilot -n "__fish_copilot_needs_command" -l additional-mcp-config -d 'Additional MCP servers configuration as JSON string or file path (prefix with @) (can be used multiple times; augments config from ~/.copilot/mcp-config.json for this session). A relative @ path resolves against the session working directory (the --resume/--worktree/-C directory) and a leading ~/ expands to your home directory' -r
complete -c copilot -n "__fish_copilot_needs_command" -l additional-content-exclusion-policies -d 'Additional content exclusion policies as JSON string or file path (prefix with @) (can be used multiple times)' -r
complete -c copilot -n "__fish_copilot_needs_command" -l allow-tool -d 'Tools the CLI has permission to use; will not prompt for permission' -r
complete -c copilot -n "__fish_copilot_needs_command" -l deny-tool -d 'Tools the CLI does not have permission to use; will not prompt for permission' -r
complete -c copilot -n "__fish_copilot_needs_command" -l available-tools -d 'Only these tools will be available to the model' -r
complete -c copilot -n "__fish_copilot_needs_command" -l excluded-tools -d 'These tools will not be available to the model' -r
complete -c copilot -n "__fish_copilot_needs_command" -l secret-env-vars -d 'Environment variable names whose values are stripped from shell and MCP server environments and redacted from output (e.g., --secret-env-vars=MY_KEY,OTHER_KEY)' -r
complete -c copilot -n "__fish_copilot_needs_command" -l allow-url -d 'Allow access to specific URLs or domains' -r
complete -c copilot -n "__fish_copilot_needs_command" -l deny-url -d 'Deny access to specific URLs or domains, takes precedence over --allow-url' -r
complete -c copilot -n "__fish_copilot_needs_command" -l max-autopilot-continues -d 'Maximum number of continuation messages in autopilot mode' -r
complete -c copilot -n "__fish_copilot_needs_command" -l mode -d 'Set the initial agent mode' -r -f -a "interactive\t''
plan\t''
autopilot\t''"
complete -c copilot -n "__fish_copilot_needs_command" -l bash-env -d 'Enable BASH_ENV support for bash shells (on|off)' -r
complete -c copilot -n "__fish_copilot_needs_command" -l mouse -d 'Enable mouse support in alt screen mode (on|off)' -r
complete -c copilot -n "__fish_copilot_needs_command" -l host -d 'Host address to bind server to (default: 127.0.0.1)' -r
complete -c copilot -n "__fish_copilot_needs_command" -l port -d 'Port to listen on when in server mode (default: random available port)' -r
complete -c copilot -n "__fish_copilot_needs_command" -l session-idle-timeout -d 'Session idle timeout in seconds (0 = disabled)' -r
complete -c copilot -n "__fish_copilot_needs_command" -l auth-token-env -d 'Read auth token from specified environment variable (for SDK use)' -r
complete -c copilot -n "__fish_copilot_needs_command" -l collect-debug-logs -d 'Collect debug logs for a session and save to a .tgz file' -r
complete -c copilot -n "__fish_copilot_needs_command" -l collect-debug-logs-output -d 'Output path for --collect-debug-logs (default: copilot-debug-logs-<sessionId>.tgz in cwd)' -r
complete -c copilot -n "__fish_copilot_needs_command" -l ahp -d 'Experimental: attach to an Agent Host Protocol host and run its sessions (default: ws://127.0.0.1:8765)' -r
complete -c copilot -n "__fish_copilot_needs_command" -l environment-id -d 'Target environment id for --relay' -r
complete -c copilot -n "__fish_copilot_needs_command" -l listen -d 'Address --ahp-host binds, as host:port' -r
complete -c copilot -n "__fish_copilot_needs_command" -l workspace -d 'Directory --ahp-host runs its session in' -r
complete -c copilot -n "__fish_copilot_needs_command" -l dynamic-retrieval -d 'Enable or disable embeddings-based dynamic retrieval per category and persist the choice (category: skills). Repeatable, e.g. --dynamic-retrieval skills=off' -r
complete -c copilot -n "__fish_copilot_needs_command" -l enable-mcp-server -d 'Enable an MCP server disabled in settings for this run only; nothing is persisted (can be used multiple times)' -r
complete -c copilot -n "__fish_copilot_needs_command" -l max-ai-credits -d 'Set max AI credits for this session' -r
complete -c copilot -n "__fish_copilot_needs_command" -l usage-output-file -d 'Write final usage statistics as JSON to the specified file' -r
complete -c copilot -n "__fish_copilot_needs_command" -s v -l version -d 'show version information'
complete -c copilot -n "__fish_copilot_needs_command" -l fleet -d 'Run the prompt in fleet mode (parallel subagent orchestration); combine with -i, -p, or piped stdin'
complete -c copilot -n "__fish_copilot_needs_command" -s s -l silent -d 'Output only the agent response (no stats), useful for scripting with -p'
complete -c copilot -n "__fish_copilot_needs_command" -l enable-memory -d 'Enable memory in prompt mode (disabled by default)'
complete -c copilot -n "__fish_copilot_needs_command" -l enable-reasoning-summaries -d 'Deprecated compatibility flag (accepted but ignored)'
complete -c copilot -n "__fish_copilot_needs_command" -l continue -d 'Resume the most recent session'
complete -c copilot -n "__fish_copilot_needs_command" -l cloud -d 'Create a cloud sandbox session and connect to it'
complete -c copilot -n "__fish_copilot_needs_command" -l allow-all-tools -d 'Allow all tools to run automatically without confirmation; required for non-interactive mode. Run `copilot help environment` for what COPILOT_ALLOW_ALL accepts and what exact "true" grants'
complete -c copilot -n "__fish_copilot_needs_command" -l allow-all-paths -d 'Disable file path verification and allow access to any path'
complete -c copilot -n "__fish_copilot_needs_command" -l disallow-temp-dir -d 'Prevent automatic access to the system temporary directory'
complete -c copilot -n "__fish_copilot_needs_command" -l banner -d 'Show the startup banner'
complete -c copilot -n "__fish_copilot_needs_command" -l screen-reader -d 'Enable screen reader optimizations'
complete -c copilot -n "__fish_copilot_needs_command" -l plain-diff -d 'Disable rich diff rendering (syntax highlighting via diff tool specified by git config)'
complete -c copilot -n "__fish_copilot_needs_command" -l share-gist -d 'Share session to a secret GitHub gist after completion in non-interactive mode'
complete -c copilot -n "__fish_copilot_needs_command" -l disable-builtin-mcps -d 'Disable all built-in MCP servers (currently: github-mcp-server)'
complete -c copilot -n "__fish_copilot_needs_command" -l enable-all-github-mcp-tools -d 'Enable all GitHub MCP server tools instead of the default CLI subset. Overrides --add-github-mcp-toolset and --add-github-mcp-tool options.'
complete -c copilot -n "__fish_copilot_needs_command" -l allow-all-mcp-server-instructions -d 'Include initialization instructions from all MCP servers in the system prompt instead of only allowlisted servers'
complete -c copilot -n "__fish_copilot_needs_command" -l allow-all-urls -d 'Allow access to all URLs without confirmation'
complete -c copilot -n "__fish_copilot_needs_command" -l allow-all -d 'Enable all permissions (equivalent to --allow-all-tools --allow-all-paths --allow-all-urls)'
complete -c copilot -n "__fish_copilot_needs_command" -l yolo -d 'Enable all permissions (equivalent to --allow-all-tools --allow-all-paths --allow-all-urls)'
complete -c copilot -n "__fish_copilot_needs_command" -l autopilot -d 'Start in autopilot mode'
complete -c copilot -n "__fish_copilot_needs_command" -l plan -d 'Start in plan mode (combine with --mode autopilot to auto-approve the plan and implement it autonomously)'
complete -c copilot -n "__fish_copilot_needs_command" -l experimental -d 'Enable experimental features'
complete -c copilot -n "__fish_copilot_needs_command" -l show-timing -d 'Show LLM turn duration timing information. For accurate tool timing, consider using --allow-all-tools to avoid confirmation delays.'
complete -c copilot -n "__fish_copilot_needs_command" -l server -d 'Enable headless JSON-RPC server mode'
complete -c copilot -n "__fish_copilot_needs_command" -l ui-server -d 'Enable TUI with embedded JSON-RPC server'
complete -c copilot -n "__fish_copilot_needs_command" -l headless -d 'Enable headless JSON-RPC server mode (alias for --server)'
complete -c copilot -n "__fish_copilot_needs_command" -l managed-server -d 'Bootstrap a managed-server session under headless --server so a controller\'s attach picker can drive it'
complete -c copilot -n "__fish_copilot_needs_command" -l acp -d 'Start as Agent Client Protocol server'
complete -c copilot -n "__fish_copilot_needs_command" -l stdio -d 'Use stdio transport for server mode (instead of TCP)'
complete -c copilot -n "__fish_copilot_needs_command" -l disable-remote-sessions -d 'Disable remote session access'
complete -c copilot -n "__fish_copilot_needs_command" -l remote -d 'Enable remote control of your session from GitHub web and mobile'
complete -c copilot -n "__fish_copilot_needs_command" -l remote-export -d 'Export your session to GitHub web and mobile (read-only; does not enable remote control)'
complete -c copilot -n "__fish_copilot_needs_command" -l log-interactive-shells -d 'Log raw PTY data from interactive shell sessions'
complete -c copilot -n "__fish_copilot_needs_command" -l print-debug-info -d 'Print CLI version, terminal capabilities, and detection-related env vars, then exit'
complete -c copilot -n "__fish_copilot_needs_command" -l relay -d 'Experimental: connect to a remote agent host via Mission Control + Web PubSub relay'
complete -c copilot -n "__fish_copilot_needs_command" -l ahp-host -d 'Experimental: run as an Agent Host Protocol host'
complete -c copilot -n "__fish_copilot_needs_command" -l sandbox -d 'Run this session\'s shell commands inside the OS-level sandbox for this run only (does not change your saved sandbox setting)'
complete -c copilot -n "__fish_copilot_needs_command" -l assisted-approval -d 'Review tool permission requests with the assisted-approval safety judge instead of approving them outright. Equivalent to the `assisted` mode of /permissions. Takes precedence over --allow-all-tools when the judge engages; requires --experimental or enabledFeatureFlags.AUTO_APPROVAL. (env: COPILOT_ASSISTED_APPROVAL)'
complete -c copilot -n "__fish_copilot_needs_command" -l embedded-host -d 'Run as an in-process FFI embedded host (Rust engine driven over the C ABI; no stdio/TCP transport)'
complete -c copilot -n "__fish_copilot_needs_command" -l no-custom-instructions -d 'Disable loading of custom instructions from AGENTS.md and related files'
complete -c copilot -n "__fish_copilot_needs_command" -l no-auto-update -d 'Disable downloading CLI updates automatically. Copilot then runs the version bundled in the executable you launched rather than a newer previously downloaded one'
complete -c copilot -n "__fish_copilot_needs_command" -l no-ask-user -d 'Disable the ask_user tool (agent works autonomously without asking questions)'
complete -c copilot -n "__fish_copilot_needs_command" -l no-color -d 'Disable all color output'
complete -c copilot -n "__fish_copilot_needs_command" -l no-experimental -d 'Disable experimental features'
complete -c copilot -n "__fish_copilot_needs_command" -l no-bash-env -d 'Disable BASH_ENV support for bash shells'
complete -c copilot -n "__fish_copilot_needs_command" -l no-mouse -d 'Disable mouse support in alt screen mode'
complete -c copilot -n "__fish_copilot_needs_command" -l no-remote -d 'Disable remote control of your session from GitHub web and mobile'
complete -c copilot -n "__fish_copilot_needs_command" -l no-remote-export -d 'Disable exporting your session to GitHub web and mobile (also disables remote control)'
complete -c copilot -n "__fish_copilot_needs_command" -l no-auto-login -d 'Disable automatic login detection (stored OAuth tokens and gh CLI)'
complete -c copilot -n "__fish_copilot_needs_command" -l no-sandbox -d 'Disable the OS-level sandbox for this run only (does not change your saved sandbox setting)'
complete -c copilot -n "__fish_copilot_needs_command" -l no-eager-powershell-resolution -d 'Disable background PowerShell prompt resolution on Windows'
complete -c copilot -n "__fish_copilot_needs_command" -s h -l help -d 'Print help'
complete -c copilot -n "__fish_copilot_needs_command" -f -a "app" -d 'Open the GitHub Copilot app'
complete -c copilot -n "__fish_copilot_needs_command" -f -a "login" -d 'Authenticate with Copilot'
complete -c copilot -n "__fish_copilot_needs_command" -f -a "help" -d 'Display help information'
complete -c copilot -n "__fish_copilot_needs_command" -f -a "init" -d 'Initialize Copilot instructions'
complete -c copilot -n "__fish_copilot_needs_command" -f -a "update" -d 'Download the latest version'
complete -c copilot -n "__fish_copilot_needs_command" -f -a "version" -d 'Display version information'
complete -c copilot -n "__fish_copilot_needs_command" -f -a "workflow" -d 'Run dynamic workflows'
complete -c copilot -n "__fish_copilot_needs_command" -f -a "sessions" -d 'Manage saved sessions'
complete -c copilot -n "__fish_copilot_needs_command" -f -a "memories" -d 'Manage memories'
complete -c copilot -n "__fish_copilot_needs_command" -f -a "plugin" -d 'Manage plugins'
complete -c copilot -n "__fish_copilot_needs_command" -f -a "mcp" -d 'Manage MCP servers'
complete -c copilot -n "__fish_copilot_needs_command" -f -a "skill" -d 'Manage skills'
complete -c copilot -n "__fish_copilot_needs_command" -f -a "instruction" -d 'Inspect instruction sources'
complete -c copilot -n "__fish_copilot_needs_command" -f -a "lsp" -d 'Inspect language server configuration'
complete -c copilot -n "__fish_copilot_needs_command" -f -a "taskbar-selftest" -d 'Diagnose the Windows taskbar-presence (Forerunner) pipeline'
complete -c copilot -n "__fish_copilot_needs_command" -f -a "completion" -d 'Generate a shell completion script'
complete -c copilot -n "__fish_copilot_using_subcommand app" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -n "__fish_copilot_using_subcommand login" -l host -d 'GitHub host URL (default: https://github.com)' -r
complete -c copilot -n "__fish_copilot_using_subcommand login" -l config-dir -d 'Set the configuration directory (deprecated: use COPILOT_HOME env var)' -r
complete -c copilot -n "__fish_copilot_using_subcommand login" -l device-code -d 'Authenticate using the OAuth device code flow (default in remote or headless environments)'
complete -c copilot -n "__fish_copilot_using_subcommand login" -l web-flow -d 'Authenticate using the browser (web) flow (default on local desktops)'
complete -c copilot -n "__fish_copilot_using_subcommand login" -l with-token -d 'Read an authentication token from standard input'
complete -c copilot -n "__fish_copilot_using_subcommand login" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -n "__fish_copilot_using_subcommand help" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -n "__fish_copilot_using_subcommand init" -l sandbox -d 'Run this session\'s shell commands inside the OS-level sandbox for this run only (does not change your saved sandbox setting)'
complete -c copilot -n "__fish_copilot_using_subcommand init" -l experimental -d 'Enable experimental features'
complete -c copilot -n "__fish_copilot_using_subcommand init" -l no-sandbox -d 'Disable the OS-level sandbox for this run only (does not change your saved sandbox setting)'
complete -c copilot -n "__fish_copilot_using_subcommand init" -l no-experimental -d 'Disable experimental features'
complete -c copilot -n "__fish_copilot_using_subcommand init" -l no-eager-powershell-resolution -d 'Disable background PowerShell prompt resolution on Windows'
complete -c copilot -n "__fish_copilot_using_subcommand init" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -n "__fish_copilot_using_subcommand update" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -n "__fish_copilot_using_subcommand version" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -n "__fish_copilot_using_subcommand workflow; and not __fish_seen_subcommand_from run" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -n "__fish_copilot_using_subcommand workflow; and not __fish_seen_subcommand_from run" -f -a "run" -d 'Run a registered dynamic workflow'
complete -c copilot -n "__fish_copilot_using_subcommand workflow; and __fish_seen_subcommand_from run" -l args -d 'Workflow arguments as inline JSON or an @-prefixed JSON file' -r
complete -c copilot -n "__fish_copilot_using_subcommand workflow; and __fish_seen_subcommand_from run" -l result-file -d 'Write only the workflow result to this JSON file' -r
complete -c copilot -n "__fish_copilot_using_subcommand workflow; and __fish_seen_subcommand_from run" -l output-format -d 'Output format: \'text\' (default) or \'json\' (JSONL)' -r -f -a "text\t''
json\t''"
complete -c copilot -n "__fish_copilot_using_subcommand workflow; and __fish_seen_subcommand_from run" -s s -l silent -d 'Suppress workflow progress output'
complete -c copilot -n "__fish_copilot_using_subcommand workflow; and __fish_seen_subcommand_from run" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -n "__fish_copilot_using_subcommand sessions; and not __fish_seen_subcommand_from import" -s h -l help -d 'Print help'
complete -c copilot -n "__fish_copilot_using_subcommand sessions; and not __fish_seen_subcommand_from import" -f -a "import" -d 'Import a semantic session from JSONL'
complete -c copilot -n "__fish_copilot_using_subcommand sessions; and __fish_seen_subcommand_from import" -l output -d 'Output format' -r -f -a "json\t''"
complete -c copilot -n "__fish_copilot_using_subcommand sessions; and __fish_seen_subcommand_from import" -l working-directory -d 'Override the imported working directory' -r
complete -c copilot -n "__fish_copilot_using_subcommand sessions; and __fish_seen_subcommand_from import" -l name -d 'Override the imported session name' -r
complete -c copilot -n "__fish_copilot_using_subcommand sessions; and __fish_seen_subcommand_from import" -l dry-run -d 'Validate without writing a session'
complete -c copilot -n "__fish_copilot_using_subcommand sessions; and __fish_seen_subcommand_from import" -s h -l help -d 'Print help'
complete -c copilot -n "__fish_copilot_using_subcommand memories; and not __fish_seen_subcommand_from import" -s h -l help -d 'Print help'
complete -c copilot -n "__fish_copilot_using_subcommand memories; and not __fish_seen_subcommand_from import" -f -a "import" -d 'Import semantic memories through the native memory service'
complete -c copilot -n "__fish_copilot_using_subcommand memories; and __fish_seen_subcommand_from import" -l output -d 'Output format' -r -f -a "json\t''"
complete -c copilot -n "__fish_copilot_using_subcommand memories; and __fish_seen_subcommand_from import" -l on-conflict -d 'Conflict behavior' -r -f -a "skip\t''
error\t''"
complete -c copilot -n "__fish_copilot_using_subcommand memories; and __fish_seen_subcommand_from import" -l dry-run -d 'Validate without submitting memories'
complete -c copilot -n "__fish_copilot_using_subcommand memories; and __fish_seen_subcommand_from import" -s h -l help -d 'Print help'
complete -c copilot -n "__fish_copilot_using_subcommand plugin; and not __fish_seen_subcommand_from install uninstall update list enable disable marketplace" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -n "__fish_copilot_using_subcommand plugin; and not __fish_seen_subcommand_from install uninstall update list enable disable marketplace" -f -a "install" -d 'Install a plugin'
complete -c copilot -n "__fish_copilot_using_subcommand plugin; and not __fish_seen_subcommand_from install uninstall update list enable disable marketplace" -f -a "uninstall" -d 'Uninstall a plugin'
complete -c copilot -n "__fish_copilot_using_subcommand plugin; and not __fish_seen_subcommand_from install uninstall update list enable disable marketplace" -f -a "update" -d 'Update a plugin'
complete -c copilot -n "__fish_copilot_using_subcommand plugin; and not __fish_seen_subcommand_from install uninstall update list enable disable marketplace" -f -a "list" -d 'List installed and --plugin-dir plugins'
complete -c copilot -n "__fish_copilot_using_subcommand plugin; and not __fish_seen_subcommand_from install uninstall update list enable disable marketplace" -f -a "enable" -d 'Enable a plugin'
complete -c copilot -n "__fish_copilot_using_subcommand plugin; and not __fish_seen_subcommand_from install uninstall update list enable disable marketplace" -f -a "disable" -d 'Disable a plugin'
complete -c copilot -n "__fish_copilot_using_subcommand plugin; and not __fish_seen_subcommand_from install uninstall update list enable disable marketplace" -f -a "marketplace" -d 'Manage plugin marketplaces'
complete -c copilot -n "__fish_copilot_using_subcommand plugin; and __fish_seen_subcommand_from install" -l config-dir -d 'Path to the configuration directory (deprecated: use COPILOT_HOME env var)' -r
complete -c copilot -n "__fish_copilot_using_subcommand plugin; and __fish_seen_subcommand_from install" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -n "__fish_copilot_using_subcommand plugin; and __fish_seen_subcommand_from uninstall" -l config-dir -d 'Path to the configuration directory (deprecated: use COPILOT_HOME env var)' -r
complete -c copilot -n "__fish_copilot_using_subcommand plugin; and __fish_seen_subcommand_from uninstall" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -n "__fish_copilot_using_subcommand plugin; and __fish_seen_subcommand_from update" -l config-dir -d 'Path to the configuration directory (deprecated: use COPILOT_HOME env var)' -r
complete -c copilot -n "__fish_copilot_using_subcommand plugin; and __fish_seen_subcommand_from update" -l all -d 'Update all installed plugins'
complete -c copilot -n "__fish_copilot_using_subcommand plugin; and __fish_seen_subcommand_from update" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -n "__fish_copilot_using_subcommand plugin; and __fish_seen_subcommand_from list" -l config-dir -d 'Path to the configuration directory (deprecated: use COPILOT_HOME env var)' -r
complete -c copilot -n "__fish_copilot_using_subcommand plugin; and __fish_seen_subcommand_from list" -l json -d 'Output as JSON'
complete -c copilot -n "__fish_copilot_using_subcommand plugin; and __fish_seen_subcommand_from list" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -n "__fish_copilot_using_subcommand plugin; and __fish_seen_subcommand_from enable" -l config-dir -d 'Path to the configuration directory (deprecated: use COPILOT_HOME env var)' -r
complete -c copilot -n "__fish_copilot_using_subcommand plugin; and __fish_seen_subcommand_from enable" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -n "__fish_copilot_using_subcommand plugin; and __fish_seen_subcommand_from disable" -l config-dir -d 'Path to the configuration directory (deprecated: use COPILOT_HOME env var)' -r
complete -c copilot -n "__fish_copilot_using_subcommand plugin; and __fish_seen_subcommand_from disable" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -n "__fish_copilot_using_subcommand plugin; and __fish_seen_subcommand_from marketplace" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -n "__fish_copilot_using_subcommand plugin; and __fish_seen_subcommand_from marketplace" -f -a "add" -d 'Add a marketplace'
complete -c copilot -n "__fish_copilot_using_subcommand plugin; and __fish_seen_subcommand_from marketplace" -f -a "remove" -d 'Remove a marketplace'
complete -c copilot -n "__fish_copilot_using_subcommand plugin; and __fish_seen_subcommand_from marketplace" -f -a "list" -d 'List registered marketplaces'
complete -c copilot -n "__fish_copilot_using_subcommand plugin; and __fish_seen_subcommand_from marketplace" -f -a "browse" -d 'Browse plugins in a marketplace'
complete -c copilot -n "__fish_copilot_using_subcommand plugin; and __fish_seen_subcommand_from marketplace" -f -a "update" -d 'Update marketplace plugin catalogs'
complete -c copilot -n "__fish_copilot_using_subcommand mcp; and not __fish_seen_subcommand_from list get add remove enable disable" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -n "__fish_copilot_using_subcommand mcp; and not __fish_seen_subcommand_from list get add remove enable disable" -f -a "list" -d 'List configured MCP servers'
complete -c copilot -n "__fish_copilot_using_subcommand mcp; and not __fish_seen_subcommand_from list get add remove enable disable" -f -a "get" -d 'Show server details'
complete -c copilot -n "__fish_copilot_using_subcommand mcp; and not __fish_seen_subcommand_from list get add remove enable disable" -f -a "add" -d 'Add an MCP server'
complete -c copilot -n "__fish_copilot_using_subcommand mcp; and not __fish_seen_subcommand_from list get add remove enable disable" -f -a "remove" -d 'Remove an MCP server'
complete -c copilot -n "__fish_copilot_using_subcommand mcp; and not __fish_seen_subcommand_from list get add remove enable disable" -f -a "enable" -d 'Enable an MCP server'
complete -c copilot -n "__fish_copilot_using_subcommand mcp; and not __fish_seen_subcommand_from list get add remove enable disable" -f -a "disable" -d 'Disable an MCP server'
complete -c copilot -n "__fish_copilot_using_subcommand mcp; and __fish_seen_subcommand_from list" -l config-dir -d 'Path to the configuration directory (deprecated: use COPILOT_HOME env var)' -r
complete -c copilot -n "__fish_copilot_using_subcommand mcp; and __fish_seen_subcommand_from list" -l json -d 'Output as JSON'
complete -c copilot -n "__fish_copilot_using_subcommand mcp; and __fish_seen_subcommand_from list" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -n "__fish_copilot_using_subcommand mcp; and __fish_seen_subcommand_from get" -l config-dir -d 'Path to the configuration directory (deprecated: use COPILOT_HOME env var)' -r
complete -c copilot -n "__fish_copilot_using_subcommand mcp; and __fish_seen_subcommand_from get" -l json -d 'Output as JSON'
complete -c copilot -n "__fish_copilot_using_subcommand mcp; and __fish_seen_subcommand_from get" -l show-secrets -d 'Show full environment variable and header values (masked by default)'
complete -c copilot -n "__fish_copilot_using_subcommand mcp; and __fish_seen_subcommand_from get" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -n "__fish_copilot_using_subcommand mcp; and __fish_seen_subcommand_from add" -l transport -d 'Server transport' -r -f -a "stdio\t''
http\t''
sse\t''"
complete -c copilot -n "__fish_copilot_using_subcommand mcp; and __fish_seen_subcommand_from add" -l env -d 'Environment variable (KEY=VALUE, can be repeated)' -r
complete -c copilot -n "__fish_copilot_using_subcommand mcp; and __fish_seen_subcommand_from add" -l header -d 'HTTP header for remote servers, can be repeated' -r
complete -c copilot -n "__fish_copilot_using_subcommand mcp; and __fish_seen_subcommand_from add" -l tools -d 'Tool filter: "*" for all, comma-separated list, or "" for none' -r
complete -c copilot -n "__fish_copilot_using_subcommand mcp; and __fish_seen_subcommand_from add" -l timeout -d 'Timeout in milliseconds (1-4294967295)' -r
complete -c copilot -n "__fish_copilot_using_subcommand mcp; and __fish_seen_subcommand_from add" -l config-dir -d 'Path to the configuration directory (deprecated: use COPILOT_HOME env var)' -r
complete -c copilot -n "__fish_copilot_using_subcommand mcp; and __fish_seen_subcommand_from add" -l json -d 'Output added config as JSON'
complete -c copilot -n "__fish_copilot_using_subcommand mcp; and __fish_seen_subcommand_from add" -l show-secrets -d 'Show full environment variable and header values in output, masked by default'
complete -c copilot -n "__fish_copilot_using_subcommand mcp; and __fish_seen_subcommand_from add" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -n "__fish_copilot_using_subcommand mcp; and __fish_seen_subcommand_from remove" -l config-dir -d 'Path to the configuration directory (deprecated: use COPILOT_HOME env var)' -r
complete -c copilot -n "__fish_copilot_using_subcommand mcp; and __fish_seen_subcommand_from remove" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -n "__fish_copilot_using_subcommand mcp; and __fish_seen_subcommand_from enable" -l config-dir -d 'Path to the configuration directory (deprecated: use COPILOT_HOME env var)' -r
complete -c copilot -n "__fish_copilot_using_subcommand mcp; and __fish_seen_subcommand_from enable" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -n "__fish_copilot_using_subcommand mcp; and __fish_seen_subcommand_from disable" -l config-dir -d 'Path to the configuration directory (deprecated: use COPILOT_HOME env var)' -r
complete -c copilot -n "__fish_copilot_using_subcommand mcp; and __fish_seen_subcommand_from disable" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -n "__fish_copilot_using_subcommand skill; and not __fish_seen_subcommand_from list add remove enable disable" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -n "__fish_copilot_using_subcommand skill; and not __fish_seen_subcommand_from list add remove enable disable" -f -a "list" -d 'List available skills'
complete -c copilot -n "__fish_copilot_using_subcommand skill; and not __fish_seen_subcommand_from list add remove enable disable" -f -a "add" -d 'Add a skill from a file, URL, or directory'
complete -c copilot -n "__fish_copilot_using_subcommand skill; and not __fish_seen_subcommand_from list add remove enable disable" -f -a "remove" -d 'Remove a skill or custom skill directory'
complete -c copilot -n "__fish_copilot_using_subcommand skill; and not __fish_seen_subcommand_from list add remove enable disable" -f -a "enable" -d 'Enable a skill'
complete -c copilot -n "__fish_copilot_using_subcommand skill; and not __fish_seen_subcommand_from list add remove enable disable" -f -a "disable" -d 'Disable a skill'
complete -c copilot -n "__fish_copilot_using_subcommand skill; and __fish_seen_subcommand_from list" -l config-dir -d 'Path to the configuration directory (deprecated: use COPILOT_HOME env var)' -r
complete -c copilot -n "__fish_copilot_using_subcommand skill; and __fish_seen_subcommand_from list" -l json -d 'Output as JSON'
complete -c copilot -n "__fish_copilot_using_subcommand skill; and __fish_seen_subcommand_from list" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -n "__fish_copilot_using_subcommand skill; and __fish_seen_subcommand_from add" -l config-dir -d 'Path to the configuration directory (deprecated: use COPILOT_HOME env var)' -r
complete -c copilot -n "__fish_copilot_using_subcommand skill; and __fish_seen_subcommand_from add" -l project -d 'Install the skill into the project\'s .github/skills directory'
complete -c copilot -n "__fish_copilot_using_subcommand skill; and __fish_seen_subcommand_from add" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -n "__fish_copilot_using_subcommand skill; and __fish_seen_subcommand_from remove" -l config-dir -d 'Path to the configuration directory (deprecated: use COPILOT_HOME env var)' -r
complete -c copilot -n "__fish_copilot_using_subcommand skill; and __fish_seen_subcommand_from remove" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -n "__fish_copilot_using_subcommand skill; and __fish_seen_subcommand_from enable" -l config-dir -d 'Path to the configuration directory (deprecated: use COPILOT_HOME env var)' -r
complete -c copilot -n "__fish_copilot_using_subcommand skill; and __fish_seen_subcommand_from enable" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -n "__fish_copilot_using_subcommand skill; and __fish_seen_subcommand_from disable" -l config-dir -d 'Path to the configuration directory (deprecated: use COPILOT_HOME env var)' -r
complete -c copilot -n "__fish_copilot_using_subcommand skill; and __fish_seen_subcommand_from disable" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -n "__fish_copilot_using_subcommand instruction; and not __fish_seen_subcommand_from list" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -n "__fish_copilot_using_subcommand instruction; and not __fish_seen_subcommand_from list" -f -a "list" -d 'List discovered instruction sources'
complete -c copilot -n "__fish_copilot_using_subcommand instruction; and __fish_seen_subcommand_from list" -l config-dir -d 'Path to the configuration directory (deprecated: use COPILOT_HOME env var)' -r
complete -c copilot -n "__fish_copilot_using_subcommand instruction; and __fish_seen_subcommand_from list" -l json -d 'Output as JSON'
complete -c copilot -n "__fish_copilot_using_subcommand instruction; and __fish_seen_subcommand_from list" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -n "__fish_copilot_using_subcommand lsp; and not __fish_seen_subcommand_from list" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -n "__fish_copilot_using_subcommand lsp; and not __fish_seen_subcommand_from list" -f -a "list" -d 'List configured language servers'
complete -c copilot -n "__fish_copilot_using_subcommand lsp; and __fish_seen_subcommand_from list" -l config-dir -d 'Path to the configuration directory (deprecated: use COPILOT_HOME env var)' -r
complete -c copilot -n "__fish_copilot_using_subcommand lsp; and __fish_seen_subcommand_from list" -l json -d 'Output as JSON'
complete -c copilot -n "__fish_copilot_using_subcommand lsp; and __fish_seen_subcommand_from list" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -n "__fish_copilot_using_subcommand taskbar-selftest" -l strict -d 'Exit non-zero unless tasks.json was actually written'
complete -c copilot -n "__fish_copilot_using_subcommand taskbar-selftest" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -n "__fish_copilot_using_subcommand completion" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c copilot -l model -r -f -a 'auto claude-sonnet-5 claude-fable-5.1 claude-fable-5 claude-opus-5.5 claude-opus-5 claude-opus-4.8 claude-opus-4.8-fast claude-opus-4.7 claude-sonnet-4.6 claude-haiku-4.5 gpt-6-sol gpt-6-luna gpt-6-astra gpt-5.6-sol gpt-5.6-terra gpt-5.6-luna gpt-5.5 gpt-5.4 gpt-5.4-mini gpt-5.3-codex gpt-5-mini mai-code-1.1-flash gemini-3.8-flash gemini-3.7-flash gemini-3.6-flash gemini-3.5-flash grok-4.5 kimi-k3 kimi-k2.7-code'
complete -c copilot -l reasoning-effort -r -f -a 'none minimal low medium high xhigh max'
complete -c copilot -l context -r -f -a 'default long_context'
complete -c copilot -l auto-tier -r -f -a 'efficiency balance intelligence'
complete -c copilot -l log-level -r -f -a 'none error warning info debug all default'
complete -c copilot -l stream -r -f -a 'on off'
complete -c copilot -l output-format -r -f -a 'text json'
complete -c copilot -l mode -r -f -a 'interactive plan autopilot'
complete -c copilot -n "__fish_copilot_using_subcommand update" -f -a 'stable prerelease'
complete -c copilot -l output -r -f -a 'json'
complete -c copilot -l on-conflict -r -f -a 'skip error'
complete -c copilot -l transport -r -f -a 'stdio http sse'
complete -c copilot -n "__fish_copilot_using_subcommand completion" -f -a 'bash zsh fish'
