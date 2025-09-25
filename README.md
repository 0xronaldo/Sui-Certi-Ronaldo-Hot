![banner](./imagenes/banner.jpg)

# Sistema de Gestión de Empresas - Hecho en Sui

El contrato implementa un sistema de gestión de empresas con registro de clientes, niveles de membresía y aplicación de descuentos.


## El contrato fue desplegado aca el link de la suiscan

https://suiscan.xyz/mainnet/object/0x6db13a6ae045f632048acf20824954e4ec04e2ed727a46210504510088c1132a/tx-blocks


## Estructuras de Datos
su contenido es :

### Empresa
```move
public struct Empresa has key, store {
    id: sui::object::UID,
    nombre: String,
    registro_clientes: VecMap<u16, Clientes>
}
```

### Cliente
```move
public struct Clientes has store, drop, copy {
    nombre_cliente: String,
    direccion_facturacion: String,
    ano_de_registro: u8,
    nivel_cliente: Nivel,
    lista_servicios: vector<String>
}
```

### Enum de Niveles
```move
public enum Nivel has store, drop, copy {
    cobre(Cobre),    // 5% descuento
    plata(Plata),    // 10% descuento
    oro(Oro),        // 15% descuento
    diamante(Diamante) // 20% descuento
}
```

## Funciones Disponibles (9 funciones públicas)

### 1. Crear Empresa
```bash
sui client call --package <PACKAGE_ID> --module empresa --function crear_empresa --args "Nombre Empresa"
```
- **Parámetros**: `nombre: String`, `ctx: &mut TxContext`
- **Acción**: Crea objeto `Empresa` y transfiere ownership al sender
- **Return**: Void (transfiere objeto)

### 2. Agregar Cliente
```bash
sui client call --package <PACKAGE_ID> --module empresa --function agregar_cliente --args <EMPRESA_OBJECT_ID> "Juan Perez" "Calle 123" 2024 1001
```
- **Parámetros**: `empresa: &mut Empresa`, `nombre_cliente: String`, `direccion_facturacion: String`, `ano_de_registro: u8`, `id_cliente: u16`
- **Validación**: `assert!(!empresa.registro_clientes.contains(&id_cliente), ID_EXISTE)`
- **Acción**: Inserta cliente con nivel inicial `cobre(5%)`
- **Return**: Void (modifica objeto empresa)

### 3. Agregar Servicio
```bash
sui client call --package <PACKAGE_ID> --module empresa --function agregar_servicio --args <EMPRESA_OBJECT_ID> 1001 "Servicio Premium"
```
- **Parámetros**: `empresa: &mut Empresa`, `id_cliente: u16`, `servicio: String`
- **Validación**: `assert!(empresa.registro_clientes.contains(&id_cliente), ID_NO_EXISTE)`
- **Acción**: `cliente.lista_servicios.push_back(servicio)`
- **Return**: Void

### 4. Eliminar Cliente
```bash
sui client call --package <PACKAGE_ID> --module empresa --function eliminar_cliente --args <EMPRESA_OBJECT_ID> 1001
```
- **Parámetros**: `empresa: &mut Empresa`, `id_cliente: u16`
- **Validación**: `assert!(empresa.registro_clientes.contains(&id_cliente), ID_NO_EXISTE)`
- **Acción**: `empresa.registro_clientes.remove(&id_cliente)`
- **Return**: Void

### 5. Eliminar Empresa
```bash
sui client call --package <PACKAGE_ID> --module empresa --function eliminar_empresa --args <EMPRESA_OBJECT_ID>
```
- **Parámetros**: `empresa: Empresa` (by value)
- **Acción**: Destructuring del objeto + `sui::object::delete(id)`
- **Return**: Void (objeto eliminado)

### 6-9. Cambiar Nivel de Cliente
```bash
# Nivel Cobre (5%)
sui client call --package <PACKAGE_ID> --module empresa --function cambiar_nivel_a_cobre --args <EMPRESA_OBJECT_ID> 1001

# Nivel Plata (10%)
sui client call --package <PACKAGE_ID> --module empresa --function cambiar_nivel_a_plata --args <EMPRESA_OBJECT_ID> 1001

# Nivel Oro (15%)
sui client call --package <PACKAGE_ID> --module empresa --function cambiar_nivel_a_oro --args <EMPRESA_OBJECT_ID> 1001

# Nivel Diamante (20%)
sui client call --package <PACKAGE_ID> --module empresa --function cambiar_nivel_a_diamante --args <EMPRESA_OBJECT_ID> 1001
```
- **Parámetros**: `empresa: &mut Empresa`, `id_cliente: u16`
- **Validación**: `assert!(empresa.registro_clientes.contains(&id_cliente), ID_NO_EXISTE)`
- **Acción**: Asigna nueva variante del enum `Nivel` con descuento correspondiente
- **Return**: Void

### 10. Aplicar Descuento
```bash
sui client call --package <PACKAGE_ID> --module empresa --function aplicar_descuento --args <EMPRESA_OBJECT_ID> 1001
```
- **Parámetros**: `empresa: &mut Empresa`, `id_cliente: u16`
- **Validación**: `assert!(empresa.registro_clientes.contains(&id_cliente), ID_NO_EXISTE)`
- **Lógica**: Pattern matching sobre `&cliente.nivel_cliente`
- **Return**: `String` con mensaje "Descuento aplicado del: X%"

## Constantes de Error

```move
#[error]
const ID_EXISTE: vector<u8> = b"ERROR, el id ya existe, intenta con otro numero de id";

#[error]
const ID_NO_EXISTE: vector<u8> = b"ERROR, el id de cliente no existe";
```

## Comandos de Compilación y Despliegue

### Compilar
```bash
sui move build
```

### Publicar en Testnet
```bash
sui client publish
```

### Obtener Package ID
```bash
# El Package ID se obtiene del output del comando publish
export PACKAGE_ID=<YOUR_PACKAGE_ID>
```

### Crear Empresa
```bash
# 1. Crear empresa
sui client call --package $PACKAGE_ID --module empresa --function crear_empresa --args "TechCorp SA" --gas-budget 10000000

# 2. Obtener Object ID de la respuesta y exportarlo
export EMPRESA_ID=<EMPRESA_OBJECT_ID>

# 3. Agregar cliente
sui client call --package $PACKAGE_ID --module empresa --function agregar_cliente --args $EMPRESA_ID "Ana García" "Av. Principal 456" 2024 1001

# 4. Cambiar a nivel oro
sui client call --package $PACKAGE_ID --module empresa --function cambiar_nivel_a_oro --args $EMPRESA_ID 1001

# 5. Aplicar descuento
sui client call --package $PACKAGE_ID --module empresa --function aplicar_descuento --args $EMPRESA_ID 1001
```


## Configuracion

### Testnet
```toml
[dependencies]
Sui = { git = "https://github.com/MystenLabs/sui.git", subdir = "crates/sui-framework/packages/sui-framework", rev = "framework/testnet" }
```

### Cliente Sui Setup
```bash
sui client new-env --alias testnet --rpc https://fullnode.testnet.sui.io:443
sui client switch --env testnet
sui client gas
```
