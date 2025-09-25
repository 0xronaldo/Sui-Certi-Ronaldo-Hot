module mi_empresa::empresa {
    // Importa tipos y funciones necesarias
    use std::string::{String, utf8};
    use sui::vec_map::{Self, VecMap};

    // --- ESTRUCTURAS PRINCIPALES ---

    // Define la estructura 'Empresa' que representa a una empresa con un ID único,
    // un nombre y un registro de clientes (un mapa con clave u16 y valor Clientes).
    public struct Empresa has key, store {
        id: sui::object::UID,
        nombre: String,
        registro_clientes: VecMap<u16, Clientes>
    }

    // Define la estructura 'Clientes' con información básica, nivel y lista de servicios.
    // Tiene propiedades para ser almacenado, copiado y eliminado de la memoria.
    public struct Clientes has store, drop, copy {
        nombre_cliente: String,
        direccion_facturacion: String,
        ano_de_registro: u8,
        nivel_cliente: Nivel,
        lista_servicios: vector<String>
    }

    // Enum que representa los niveles de cliente, cada uno con su propia estructura que contiene un descuento.
    public enum Nivel has store, drop, copy {
        cobre(Cobre),
        plata(Plata),
        oro(Oro),
        diamante(Diamante)
    }

    // Estructuras específicas para cada nivel, contienen el porcentaje de descuento.
    public struct Cobre has store, drop, copy {
        descuento: u8
    }
    public struct Plata has store, drop, copy {
        descuento: u8
    }
    public struct Oro has store, drop, copy {
        descuento: u8
    }
    public struct Diamante has store, drop, copy {
        descuento: u8
    }

    // --- CONSTANTES DE ERROR ---
    // Mensajes de error personalizados para validar existencia o no existencia de IDs.
    #[error]
    const ID_EXISTE: vector<u8> = b"ERROR, el id ya existe, intenta con otro numero de id";
    #[error]
    const ID_NO_EXISTE: vector<u8> = b"ERROR, el id de cliente no existe";

    // --- FUNCIONES PRINCIPALES ---

    // Crea una nueva empresa con un nombre dado y un registro vacío de clientes.
    // Se usa el contexto de la transacción para crear un objeto único global.
    #[allow(lint(self_transfer))]
    public fun crear_empresa(nombre: String, ctx: &mut sui::tx_context::TxContext) {
        let empresa = Empresa {
            id: sui::object::new(ctx),
            nombre,
            registro_clientes: vec_map::empty()
        };
        // Transfiere la propiedad del objeto empresa al emisor de la transacción.
        sui::transfer::transfer(empresa, sui::tx_context::sender(ctx));
    }

    // Agrega un nuevo cliente al registro de la empresa con datos básicos y nivel inicial 'cobre'.
    // Se asegura que el ID del cliente no exista previamente (evita duplicados).
    public fun agregar_cliente(empresa: &mut Empresa, nombre_cliente: String, direccion_facturacion: String, ano_de_registro: u8, id_cliente: u16) {
        // Se valida que el id nuevo del cliente no exista antes de proceder con la creacion del nuevo cliente.
        assert!(!empresa.registro_clientes.contains(&id_cliente), ID_EXISTE);

        let cliente = Clientes {
            nombre_cliente,
            direccion_facturacion,
            ano_de_registro,
            nivel_cliente: Nivel::cobre(Cobre{descuento: 5}), // Nivel inicial con 5% de descuento
            lista_servicios: vector[] // Lista vacía inicialmente
        };

        // Inserta el cliente en el registro con la clave id_cliente
        empresa.registro_clientes.insert(id_cliente, cliente);
    }

    // Añade un servicio a la lista de servicios de un cliente específico.
    // Verifica que el cliente exista antes de modificar.
    public fun agregar_servicio(empresa: &mut Empresa, id_cliente: u16, servicio: String) {
        // Se valida la existetncia del id del cliente previo a continuar con el codigo
        assert!(empresa.registro_clientes.contains(&id_cliente), ID_NO_EXISTE);

        // Obtiene referencia mutable al cliente para modificar su lista de servicios.
        let cliente = empresa.registro_clientes.get_mut(&id_cliente);
        cliente.lista_servicios.push_back(servicio);
    }

    // Elimina un cliente del registro de la empresa usando su ID.
    // Verifica que el cliente exista antes de eliminar.
    public fun eliminar_cliente(empresa: &mut Empresa, id_cliente: u16) {
        // Se valida la existetncia del id del cliente previo a continuar con el codigo
        assert!(empresa.registro_clientes.contains(&id_cliente), ID_NO_EXISTE);

        // Remueve la entrada del cliente del mapa
        empresa.registro_clientes.remove(&id_cliente);
    }

    // Elimina completamente el objeto empresa de la blockchain usando su ID.
    public fun eliminar_empresa(empresa: Empresa) {
        let Empresa {id, nombre:_ , registro_clientes:_ } = empresa;
        sui::object::delete(id);
    }

    // --- FUNCIONES PARA CAMBIAR EL NIVEL DEL CLIENTE ---

    // Cambia el nivel del cliente a 'cobre' con descuento 5%
    public fun cambiar_nivel_a_cobre(empresa: &mut Empresa, id_cliente: u16) {
        // Se valida la existetncia del id del cliente previo a continuar con el codigo
        assert!(empresa.registro_clientes.contains(&id_cliente), ID_NO_EXISTE);

        let cliente = empresa.registro_clientes.get_mut(&id_cliente);
        cliente.nivel_cliente = Nivel::cobre(Cobre{descuento: 5});
    }

    // Cambia el nivel del cliente a 'plata' con descuento 10%
    public fun cambiar_nivel_a_plata(empresa: &mut Empresa, id_cliente: u16) {
        // Se valida la existetncia del id del cliente previo a continuar con el codigo
        assert!(empresa.registro_clientes.contains(&id_cliente), ID_NO_EXISTE);

        let cliente = empresa.registro_clientes.get_mut(&id_cliente);
        cliente.nivel_cliente = Nivel::plata(Plata{descuento: 10});
    }

    // Cambia el nivel del cliente a 'oro' con descuento 15%
    public fun cambiar_nivel_a_oro(empresa: &mut Empresa, id_cliente: u16) {
        // Se valida la existetncia del id del cliente previo a continuar con el codigo
        assert!(empresa.registro_clientes.contains(&id_cliente), ID_NO_EXISTE);

        let cliente = empresa.registro_clientes.get_mut(&id_cliente);
        cliente.nivel_cliente = Nivel::oro(Oro{descuento: 15});
    }

    // Cambia el nivel del cliente a 'diamante' con descuento 20%
    public fun cambiar_nivel_a_diamante(empresa: &mut Empresa, id_cliente: u16) {
        // Se valida la existetncia del id del cliente previo a continuar con el codigo
        assert!(empresa.registro_clientes.contains(&id_cliente), ID_NO_EXISTE);

        // Obtiene referencia mutable al cliente
        let cliente = empresa.registro_clientes.get_mut(&id_cliente);
        cliente.nivel_cliente = Nivel::diamante(Diamante{descuento: 20});
    }

    // --- FUNCION PARA APLICAR DESCUENTO Y RETORNAR MENSAJE ---

    // Aplica el descuento según el nivel del cliente y devuelve un mensaje con el porcentaje aplicado.
    public fun aplicar_descuento(empresa: &mut Empresa, id_cliente: u16): String {
        assert!(empresa.registro_clientes.contains(&id_cliente), ID_NO_EXISTE);

        // Obtiene referencia mutable al cliente
        let cliente = empresa.registro_clientes.get_mut(&id_cliente);

        // Evalúa el nivel del cliente y retorna mensaje con porcentaje de descuento
        match(&cliente.nivel_cliente) {
            Nivel::cobre(_dato) => {
                utf8(b"Descuento aplicado del: 5%")
            },
            Nivel::plata(_dato) => {
                utf8(b"Descuento aplicado del: 10%")
            },
            Nivel::oro(_dato) => {
                utf8(b"Descuento aplicado del: 15%")
            },
            Nivel::diamante(_dato) => {
                utf8(b"Descuento aplicado del: 20%")
            }
        }
    }
}
