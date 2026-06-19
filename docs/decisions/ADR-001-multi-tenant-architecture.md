# ADR-001: Multi-Tenant Architecture

## Status

Accepted

## Date

2025-06

## Context

TeoryX permitirá que múltiples escuelas utilicen la misma plataforma.

Cada escuela tendrá:

- Estudiantes propios
- Padres propios
- Configuración propia
- Identidad visual propia
- Datos aislados

La plataforma será administrada globalmente por TeoryX mediante usuarios Super Admin.

## Decision

TeoryX será diseñado desde la versión MVP como una plataforma Multi-Tenant.

Cada entidad de negocio asociada a una escuela deberá contener:

schoolId

como identificador obligatorio de pertenencia.

## Tenant Model

TeoryX
│
├── School A
├── School B
├── School C
│
└── Super Admin

## Implications

### Positivas

- Escalable
- Preparado para múltiples escuelas
- Menor costo operativo
- Fácil administración global

### Negativas

- Reglas de seguridad más complejas
- Consultas requieren filtrado por schoolId

## Firestore Strategy

Todas las colecciones relacionadas con una escuela deberán almacenar:

schoolId

Ejemplos:

- users
- students
- parents
- lessons
- assessments
- progress

## Security Rule Principle

Un usuario solamente podrá acceder a datos asociados a su schoolId.

Super Admin podrá acceder a todos los tenants.

## Future Considerations

- Themes avanzados
- Dominios personalizados
- Configuración específica por escuela
- Licenciamiento por tenant

## Consequences

La arquitectura Multi-Tenant será considerada una restricción obligatoria para cualquier desarrollo futuro de TeoryX.
