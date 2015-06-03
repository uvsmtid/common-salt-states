
###############################################################################
#

system_features:

    # Preffered console type specified in kernel command line.
    # This is to avoid default 80x25 text buffer.
    # - Default:
    #   vga=769 - 640x480x256
    # - This parameter is comfortable enough and its VM window fits everywere:
    #   vga=792 - 1024x768
    # - This VM window may not fit inside modern wide monitor resolutions:
    #   vga=795 - 1280x1024
    # See also:
    #   http://goo.gl/kfjfJC
    set_kernel_vga_console_type_for_text_mode:
        feature_enabled: True
        vga_value: 792

###############################################################################
# EOF
###############################################################################

