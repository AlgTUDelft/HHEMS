use crate::api::demkit::ha_entity::{self, EntityRequest};
use crate::api::ha::entity;
use actix_web::{get, post, web, HttpResponse, Responder};
use serde_json::Value;
use utoipa_actix_web::scope;

pub fn configure(cfg: &mut utoipa_actix_web::service_config::ServiceConfig) {
    cfg.service(
        scope::scope("/entity")
            .service(get_entity_consumption)
            .service(get_entity_state)
            .service(set_entity_state)
            .service(toggle)
            .service(add_entity),
    );
}

#[utoipa::path(
    get,
    tag = "Entity",
    description = "Get entity consumption.",
    responses(
        (status = 200, description = "Get entity consumption", body = EntityRequest),
        (status = 500, description = "Failed to get entity consumption"),
    ),
    params(
        ("house_id" = u32, description = "House ID"),
        ("entity_name" = String, description = "Name of the entity"),
    ),
)]
#[get("/{entity_name}/consumption")]
async fn get_entity_consumption(path: web::Path<(u32, String)>) -> impl Responder {
    let entity_name = path.into_inner().1;
    match entity::get_entity_consumption(&entity_name).await {
        Ok(entity_state) => HttpResponse::Ok().json(entity_state),
        Err(e) => HttpResponse::InternalServerError()
            .body(format!("Failed to get device consumption: {}", e)),
    }
}

#[utoipa::path(
    get,
    tag = "Entity",
    description = "Get raw entity state from Home Assistant",
    responses(
        (status = 200, description = "Get entity state", body = EntityRequest),
        (status = 500, description = "Failed to get entity state"),
    ),
    params(
        ("house_id" = u32, description = "House ID"),
        ("entity_name" = String, description = "Name of the entity"),
    ),
)]
#[get("/{entity_name}/state")]
async fn get_entity_state(path: web::Path<(u32, String)>) -> impl Responder {
    let entity_name = path.into_inner().1;
    match entity::get_entity_state(&entity_name).await {
        Ok(entity_state) => HttpResponse::Ok().json(entity_state),
        Err(e) => {
            HttpResponse::InternalServerError().body(format!("Failed to get device state: {}", e))
        }
    }
}

#[utoipa::path(
    post,
    tag = "Entity",
    description = "Set entity state in Home Assistant",
    request_body = Value,
    responses(
        (status = 200, description = "Entity state set successfully"),
        (status = 500, description = "Failed to set entity state"),
    ),
    params(
        ("house_id" = u32, description = "House ID"),
        ("entity_name" = String, description = "Name of the entity"),
    ),
)]
#[post("/{entity_name}/state")]
async fn set_entity_state(
    path: web::Path<(u32, String)>,
    body: web::Json<Value>,
) -> impl Responder {
    let entity_name = path.into_inner().1;
    match entity::set_entity_state(&entity_name, body.into_inner()).await {
        Ok(entity_state) => HttpResponse::Ok().json(entity_state),
        Err(e) => {
            HttpResponse::InternalServerError().body(format!("Failed to set device state: {}", e))
        }
    }
}

#[utoipa::path(
    post,
    tag = "Entity",
    description = "Add a new entity.",
    request_body = EntityRequest,
    responses(
        (status = 200, description = "Entity added successfully"),
        (status = 500, description = "Failed to add entity"),
    ),
    request_body = EntityRequest,
    params(
        ("house_id" = u32, description = "House ID"),
    )
)]
#[post("")]
async fn add_entity(request: web::Json<EntityRequest>) -> impl Responder {
    let entity = request.into_inner();
    match ha_entity::add_entity(entity).await {
        Ok(_) => HttpResponse::Ok().body("OK"),
        Err(e) => HttpResponse::InternalServerError().body(format!("Failed to add entity, :{}", e)),
    }
}

#[utoipa::path(
    get,
    tag = "Entity",
    description = "Set entity state",
    responses(
        (status = 200, description = "Entity state set successfully"),
        (status = 500, description = "Failed to set entity state"),
    ),
    params(
        ("house_id" = u32, description = "House ID"),
        ("entity_name" = String, description = "Name of the entity"),
        ("state" = bool, description = "State to toggle to"),
    ),
)]
#[get("/{entity_name}/toggle/{state}")]
async fn toggle(id: web::Path<(u32, String, bool)>) -> impl Responder {
    let (_house_id, entity_name, state) = id.into_inner();
    match entity::toggle_entity_state(&entity_name, state).await {
        Ok(entity_states) => HttpResponse::Ok().json(entity_states),
        Err(e) => HttpResponse::InternalServerError().body(format!("Failed to toggle device state: {}", e)),
    }
}
