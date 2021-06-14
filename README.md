# microk8s-klaster-script
Shell script to install microk8s on Raspberry Pi

## How to use
Login to the Raspberry Pi using SSH and run the following command from the terminal.

The script will accept one argument which sets the device hostname. 

```
curl https://raw.githubusercontent.com/nrdyrk/microk8s-klaster-script/main/microk8s_klaster_config.sh | sudo bash -s <your-rpi-hostname>
```