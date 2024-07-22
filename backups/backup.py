import os
import yaml
import subprocess
import datetime
import shutil

DEFAULT_CONFIG_FILENAME = 'config.yml'

PGSQL_CMD = 'docker compose exec -it $CONTAINER pg_dumpall -U $USER | gzip > $BACKUP_PATH/$SERVICE.sql.gz'
MYSQL_CMD = 'docker compose exec -it $CONTAINER mysqldump -u $USER -p$PASSWORD --all-databases | gzip > $BACKUP_PATH/$SERVICE.sql.gz'

# Charger le fichier de configuration YAML
def load_config(filepath):
    with open(filepath, 'r') as file:
        return yaml.safe_load(file)

# Effectuer la sauvegarde de la base de données
def backup_database(service_name, db_type, container_name, user, password, backup_path, backup_fullpath):
    cmd = None
    
    if db_type == 'postgres':
        cmd = PGSQL_CMD
    elif db_type == 'mysql':
        cmd = MYSQL_CMD
        cmd = cmd.replace('$PASSWORD', password)
    else:
        raise ValueError(f"Unknown database type: {db_type}")
    
    cmd = cmd.replace('$CONTAINER', container_name)
    cmd = cmd.replace('$USER', user)
    cmd = cmd.replace('$SERVICE', service_name)
    cmd = cmd.replace('$BACKUP_PATH', backup_fullpath)
    
    subprocess.run(cmd, shell=True)    

# Main script
def main():
    config_path = DEFAULT_CONFIG_FILENAME
    timestamp = datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
    backup_base_path = os.path.join(f"backup_{timestamp}")
    backup_base_fullpath = os.path.join(os.getcwd(), backup_base_path)
    config = load_config(config_path)
    
    max_backups = config.get('max_backups', 5) - 1
    pwd = os.getcwd()
        
    # Delete old backups, filter with only the folder names starting with backup_
    backups = [os.path.join(pwd, f) for f in os.listdir(pwd) if os.path.isdir(os.path.join(pwd, f)) and f.startswith('backup_')]
    
    if len(backups) > max_backups:
        for backup in backups[:-max_backups]:
            print(f"Deleting old backup: {backup}")
            shutil.rmtree(backup)
            
    # Créer un répertoire pour les sauvegardes
    os.makedirs(backup_base_path, exist_ok=True)

    for service, details in config['services'].items():
        path = os.path.expanduser(details['path'])
        db_type = details['db']
        container_name = details['container']
        user = details['user']
        password = ""
        
        if 'password' in details:
            password = details['password']

        print(f"Processing {service} at {path}")
        os.chdir(path)  # Changer le répertoire de travail

        # Sauvegarde de la base de données
        backup_database(service, db_type, container_name, user, password, backup_base_path, backup_base_fullpath)
    
    print(f"Backups are saved in {backup_base_fullpath}")

if __name__ == '__main__':
    main()
