import os
import random

import wandb

if not os.path.exists(os.path.join(str(os.path.expanduser('~')), ".netrc")):
    wandb.login()

wandb.init(project="fscve", entity="kakaxdu")


