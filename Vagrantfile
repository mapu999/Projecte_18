Vagrant.configure("2") do |config|
#Elegimos versión Ubuntu
    config.vm.box = "ubuntu/xenial64"
    config.vm.provider "virtualbox" do |vb|
#Habilitamos la interfaz gráfica
        vb.gui = true
#Nombre de la máquina
        vb.name = "UbuntuServer"
#La memoria RAM que quremos
        vb.memory = "2048"
    end 
#Nombre de la máquina
    config.vm.hostname = "lamp"
#Hacemos la red privada y que nos asigne una IP aleatoria
    config.vm.network "private_network", type: "dhcp"   
end
