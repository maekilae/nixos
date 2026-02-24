{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.git = (inputs.wrappers.wrapperModules.git.apply {
      inherit pkgs;
      
      # The 'settings' block maps directly to your .gitconfig file sections
      settings = {
        user = {
          name = "Maekilae";
          email = "marcus@emph.dev";    
        };
        
        init = {
          defaultBranch = "main";
        };

        alias = {
          st = "status";
          co = "checkout";
          rb = "rebase";
        };
      };

    }).wrapper;
  };
}
