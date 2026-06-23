{
  inputs,
  ...
}:
{
  flake.modules.darwin.europa = {
    imports = with inputs.self.modules.darwin; [
      systemDev
    ];

    networking.hostName = "europa";

    # TODO: replace with this host's real SSH host pubkey for agenix-rekey
    # (the contents of /etc/ssh/ssh_host_ed25519_key.pub on europa).
    age.rekey.hostPubkey = "ssh-ed25519 AAAA_REPLACE_ME_EUROPA";

    # nix-darwin state version (integer, not a date). Refer to docs before changing.
    system.stateVersion = 5;
  };
}
