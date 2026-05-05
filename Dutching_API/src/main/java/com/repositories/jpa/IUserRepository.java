package com.repositories.jpa;

import com.entities.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface IUserRepository extends JpaRepository<User, Long> {
// Already included by default: EmpleadoVO findById(long id);
    // Al extender JpaRepository, Spring crea automáticamente:
    // - findAll()      → obtener todos los usuarios
    // - findById(id)   → obtener un usuario por ID
    // - save(usuario)  → crear o actualizar un usuario
    // - deleteById(id) → borrar un usuario
    // No es necesario escribir código adicional para CRUD básico.

List<User> findByUserName(String userName);

User findByEmail(String email);

//List<EmpleadoVO> findByTipo_jornada(String tipo_jornada);

/*
// BÚSQUEDAS BÁSICAS
findByNombre(String nombre)
findByEmail(String email)
findById(Long id)

// COMPARADORES (>, <, BETWEEN...)
findByEdadGreaterThan(int edad)        // >
findByEdadLessThan(int edad)           // <
findByEdadGreaterThanEqual(int edad)   // >=
findByEdadLessThanEqual(int edad)      // <=
findByEdadBetween(int e1, int e2)      // BETWEEN e1 AND e2

//COINCIDENCIAS PARCIALES (LIKE)
findByNombreContaining(String txt)     // LIKE %txt%
findByNombreStartsWith(String txt)     // LIKE txt%
findByNombreEndsWith(String txt)       // LIKE %txt
findByNombreNotContaining(String txt)

//BOOLEANOS
findByActivoTrue()
findByActivoFalse()

//NULOS Y NO NULOS
findByEmailIsNull()
findByEmailIsNotNull()

//ORDENACIÓN
findByNombreOrderByEdadAsc(String nombre)
findByNombreOrderByEdadDesc(String nombre)

//FILTROS CON LISTAS / IN
findByIdIn(List<Long> ids)

//JOINS AUTOMÁTICOS (RELACIONES)
//ManyToMany:
findByRolesNombre(String nombreRol)
//OneToMany / ManyToOne:
findByDireccionesCiudad(String ciudad)
findByPedidosEstado(String estado)

//VALORES DISTINTOS
findDistinctByNombre(String nombre)

//CONDICIONES AND / OR
findByNombreAndEmail(String nombre, String email)
findByNombreOrEmail(String nombre, String email)

//NEGACIONES
findByNombreNot(String nombre)
findByEdadNot(int edad)

//FECHAS
findByFechaAfter(LocalDate fecha)
findByFechaBefore(LocalDate fecha)
findByFechaBetween(LocalDate f1, LocalDate f2)

//CONSULTAS COMBINADAS
findByNombreContainingAndActivoTrue(String nombre)
findByEdadGreaterThanAndCiudad(int edad, String ciudad)
findByNombreStartingWithOrEmailEndingWith(String n, String e)

//CONTADORES
countByActivoTrue()
countByRolNombre(String rol)

//ELIMINACIONES FILTRADAS
deleteByNombre(String nombre)
deleteByActivoFalse()
deleteByEdadLessThan(int edad)

//COMPROBAR EXISTENCIA
existsByEmail(String email)
existsById(Long id)
 */





}
