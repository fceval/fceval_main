All of the projects are tested on Ubuntu 20.04 LTS.

## step1: Docker environment

```
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo apt-get -y install docker-compose
```

If you want to use Docker as a non-root user, you should consider adding the user to the docker group as follows:

```
sudo usermod -aG docker your-user
```

## step2:  python virtual environment

sudo apt install python3-virtualenv

sudo apt install virtualenv virtualenvwrapper

virtualenv --python=python3 venv

## step3:  watchdog settings

sudo gedit /etc/sysctl.conf

fs.inotify.max_user_instances=8192

fs.inotify.max_queued_events=524288

fs.inotify.max_user_watches=524288

