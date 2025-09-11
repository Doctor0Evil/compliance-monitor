use serde::{Deserialize, Serialize};
use std::fs;

#[derive(Serialize, Deserialize)]
struct Character {
    id: String,
    name: String,
    is_player: bool,
    is_god: bool,
    // other fields ...
}

// Input: vector of all characters in game data
fn delete_all_non_godmode_characters(characters: &mut Vec<Character>) {
    characters.retain(|c| c.is_god || c.is_player);
}

// Example usage
fn main() {
    // Load characters from your data file (replace file path as needed)
    let data = fs::read_to_string("game_characters.json").unwrap();
    let mut characters: Vec<Character> = serde_json::from_str(&data).unwrap();

    delete_all_non_godmode_characters(&mut characters);

    // Save back the filtered list
    fs::write("game_characters.json", serde_json::to_string_pretty(&characters).unwrap()).unwrap();
}
