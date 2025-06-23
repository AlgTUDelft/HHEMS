use std::env;

use serde::Serialize;
use serde::Deserialize;
use serde_json::Value;

use super::{init, init_load_map, ApiError, EntityState, BASE_URL, CLIENT, LOAD_MAP};

#[allow(dead_code)]
#[derive(Serialize, Deserialize, Debug)]
pub struct EntityServiceRequest {
    pub entity_id: String,
}

pub async fn get_entity_consumption(entity_id: &str) -> Result<EntityState, ApiError> {
    let client = CLIENT.get_or_init(init);
    let url = format!("{}/api/states/{}", *BASE_URL, entity_id);
    let ha_token = env::var("HA_TOKEN").expect("HA_TOKEN must be set");

    let response = client.get(url).bearer_auth(ha_token).send().await?;

    if !response.status().is_success() {
        return Err(ApiError::HomeAssistantError(
            "Failed to get device consumption".to_string(),
        ));
    }

    let response_body: EntityState = response.json::<EntityState>().await?;

    let load_map = LOAD_MAP.get_or_init(init_load_map).read().unwrap();
    if load_map.contains_key(entity_id) {
        let mut consumption = "0".to_string();

        // consumption is renamed from state
        if response_body.consumption == "on" {
            consumption = load_map.get(entity_id).unwrap().to_string();
        }

        return Ok(EntityState {
            entity_id: entity_id.to_string(),
            consumption: consumption,
        });
    } else if response_body.consumption.parse::<f64>().is_err() {
        return Err(ApiError::LoadMapError(
            "Device not found in load map".to_string(),
        ));
    }

    return Ok(EntityState {
        entity_id: entity_id.to_string(),
        consumption: response_body.consumption,
    });
}

pub async fn set_entity_state(entity_id: &str, entity_state: Value) -> Result<(), ApiError> {
    let client = CLIENT.get_or_init(init);
    let url = format!("{}/api/states/{}", *BASE_URL, entity_id);
    let ha_token = env::var("HA_TOKEN").expect("HA_TOKEN must be set");

    let response = client
        .post(url)
        .json(&entity_state)
        .bearer_auth(ha_token)
        .send()
        .await?;

    if !response.status().is_success() {
        let error_text = response
            .text()
            .await
            .unwrap_or_else(|_| "Unknown error".to_string());
        return Err(ApiError::HomeAssistantError(format!(
            "Failed to set entity state: {}",
            error_text
        )));
    }

    Ok(())
}

pub async fn get_entity_state(entity_id: &str) -> Result<Value, ApiError> {
    let client = CLIENT.get_or_init(init);
    let url = format!("{}/api/states/{}", *BASE_URL, entity_id);
    let ha_token = env::var("HA_TOKEN").expect("HA_TOKEN must be set");

    let response = client.get(url).bearer_auth(ha_token).send().await?;

    if !response.status().is_success() {
        let error_text = response
            .text()
            .await
            .unwrap_or_else(|_| "Unknown error".to_string());
        return Err(ApiError::HomeAssistantError(format!(
            "Failed to set entity state: {}",
            error_text
        )));
    }

    let response_body = response.json().await?;

    Ok(response_body)
}

pub async fn toggle_entity_state(entity_id: &str, entity_state: bool) -> Result<Value, ApiError> {
    let client = CLIENT.get_or_init(init);
    let url = format!("{}/api/services/{}/{}",
        *BASE_URL,
        entity_id.split(".").next().unwrap_or_default(),
        if entity_state { "turn_on" } else { "turn_off" }
    );
    let ha_token = env::var("HA_TOKEN").expect("HA_TOKEN must be set");

    let request = EntityServiceRequest {
        entity_id: entity_id.to_string(),
    };

    let response = client
        .post(url)
        .json(&request)
        .bearer_auth(ha_token)
        .send()
        .await?;

    if !response.status().is_success() {
        let error_text = response
            .text()
            .await
            .unwrap_or_else(|_| "Unknown error".to_string());
        return Err(ApiError::HomeAssistantError(format!(
            "Failed to set entity state: {}",
            error_text
        )));
    }

    let response_body = response.json().await?;

    Ok(response_body)
}
