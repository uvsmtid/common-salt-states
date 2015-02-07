
save_last_command_exit_code() {
    LAST_CMD_EXIT_CODE="${?}"
}

# PROMPT_COMMAND is not modified here.
# Instead, it is modified in the common script to be called first.
#PROMPT_COMMAND="save_last_command_exit_code; $PROMPT_COMMAND"

