# Configure grub (bootloader).


###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS' ] %}

# RHEL5 systems use GRUB version 1.

# Add new kernel command line if it does not contain `vga=` pattern.
# This is to add default value and make regex for
# `set_kernel_vga_console_type_for_text_mode` feature less complex.
/boot/grub/grub.conf-add_kernel_vga_console_type_for_text_mode:
    file.replace:
        - name: /boot/grub/grub.conf
        - pattern: '^(\s*kernel\s(?:(?!vga=).)*)(\s*)$'
        - repl: '\1 vga=769 \2'


#------------------------------------------------------------------------------
{% if 'disable_boot_time_splash_screen' in pillar['system_features'] %}
{% if pillar['system_features']['disable_boot_time_splash_screen'] %}
# Remove `rhgb` parameter from kernel command line.
/boot/grub/grub.conf-disable_boot_time_splash_screen:
    file.replace:
        - name: /boot/grub/grub.conf
        - pattern: '^(\s*kernel\s.*)rhgb(.*)$'
        - repl: '\1\2'
{% endif %}
{% endif %}
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
{% if 'set_kernel_vga_console_type_for_text_mode' in pillar['system_features'] %}
{% if pillar['system_features']['set_kernel_vga_console_type_for_text_mode']['feature_enabled'] %}
# Replace existing value `vga=nnn` by configured one in kernel command line.
/boot/grub/grub.conf-set_kernel_vga_console_type_for_text_mode:
    file.replace:
        - name: /boot/grub/grub.conf
        - pattern: '^(\s*kernel\s.*)vga=\d*(.*)$'
        - repl: '\1vga={{ pillar['system_features']['set_kernel_vga_console_type_for_text_mode']['vga_value'] }}\2'
        - require:
            - file: /boot/grub/grub.conf-add_kernel_vga_console_type_for_text_mode
{% endif %}
{% endif %}
#------------------------------------------------------------------------------


{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Fedora' ] %}

# Modern Linux systems use GRUB version 2.


# Add new kernel command line if it does not contain `vga=` pattern.
# This is to add default value and make regex for
# `set_kernel_vga_console_type_for_text_mode` feature less complex.
/etc/default/grub-add_kernel_vga_console_type_for_text_mode:
    file.replace:
        - name: /etc/default/grub
        - pattern: '^(\s*GRUB_CMDLINE_LINUX="(?:(?!vga=).)*)("\s*)$'
        - repl: '\1 vga=769 \2'

#------------------------------------------------------------------------------
{% if 'disable_boot_time_splash_screen' in pillar['system_features'] %}
{% if pillar['system_features']['disable_boot_time_splash_screen'] %}
# Remove `rhgb` parameter from kernel command line.
/etc/default/grub-disable_boot_time_splash_screen:
    file.replace:
        - name: /etc/default/grub
        - pattern: '^(\s*GRUB_CMDLINE_LINUX=.*)rhgb(.*)$'
        - repl: '\1\2'
{% endif %}
{% endif %}
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
{% if 'set_kernel_vga_console_type_for_text_mode' in pillar['system_features'] %}
{% if pillar['system_features']['set_kernel_vga_console_type_for_text_mode']['feature_enabled'] %}
# Replace existing value `vga=nnn` by configured one in kernel command line.
/etc/default/grub-set_kernel_vga_console_type_for_text_mode:
    file.replace:
        - name: /etc/default/grub
        - pattern: '^(\s*GRUB_CMDLINE_LINUX=.*)vga=\d*(.*)$'
        - repl: '\1vga={{ pillar['system_features']['set_kernel_vga_console_type_for_text_mode']['vga_value'] }}\2'
        - require:
            - file: /etc/default/grub-add_kernel_vga_console_type_for_text_mode
{% endif %}
{% endif %}
#------------------------------------------------------------------------------

# Different configuration files for BIOS and UEFI.
# See also:
#   http://fedoraproject.org/wiki/GRUB_2
{% if grains['system_boot_type'] == 'BIOS' %}
{% set grub_configuration_file_path = '/boot/grub2/grub.cfg' %}
grub_configuration_file:
    file.exists:
        - name: {{ grub_configuration_file_path }}
{% endif %}
{% if grains['system_boot_type'] == 'UEFI' %}
{% set grub_configuration_file_path = '/boot/efi/EFI/fedora/grub.cfg' %}
grub_configuration_file:
    file.exists:
        - name: {{ grub_configuration_file_path }}
{% endif %}

update_grub_configuration:
    cmd.run:
        - name: "grub2-mkconfig -o {{ grub_configuration_file_path }}"
        - require:
            - file: grub_configuration_file

{% endif %}
# >>>
###############################################################################

