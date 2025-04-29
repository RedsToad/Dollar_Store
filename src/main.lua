SMODS.Atlas {
    px = 34,
    py = 34,
    key = "modicon",
    path = "icon.png",
}

local function is_past_first_shop()
    return G.GAME.first_shop_buffoon or G.GAME.round_resets.blind_states.Small == "Upcoming" or
        G.GAME.round_resets.blind_states.Big ~= "Upcoming" or G.GAME.round_resets.blind_states.Boss ~= "Upcoming"
end

local function small(x)
    return type(x) == "table" and x:to_number() or x
end

local orig_get_current_pool = get_current_pool

function get_current_pool(_type, _rarity, _legendary, _append)
    local pool, pool_key = orig_get_current_pool(_type, _rarity, _legendary, _append)

    if is_past_first_shop() then
        return pool, pool_key
    end

    if _type == "Voucher" or _type == "Booster" or _append ~= "sho" then
        return pool, pool_key
    end

    for i = 1, #pool do
        local current = G.P_CENTERS[pool[i]]

        if G.GAME and (current or {}).cost and small(current.cost) > small(G.GAME.dollars) then
            pool[i] = "UNAVAILABLE"
        end
    end

    for i, v in ipairs(pool) do
        if v ~= "UNAVAILABLE" then
            return pool, pool_key
        end
    end

    if SMODS.ObjectTypes[_type] and SMODS.ObjectTypes[_type].default and G.P_CENTERS[SMODS.ObjectTypes[_type].default] then
        pool[#pool + 1] = SMODS.ObjectTypes[_type].default
    elseif _type == "Tarot" or _type == "Tarot_Planet" then
        pool[#pool + 1] = "c_strength"
    elseif _type == "Planet" then
        pool[#pool + 1] = "c_pluto"
    elseif _type == "Spectral" then
        pool[#pool + 1] = "c_incantation"
    elseif _type == "Joker" then
        pool[#pool + 1] = "j_joker"
    elseif _type == "Demo" then
        pool[#pool + 1] = "j_joker"
    elseif _type == "Voucher" then
        pool[#pool + 1] = "v_blank"
    elseif _type == "Tag" then
        pool[#pool + 1] = "tag_handy"
    elseif _type == "Consumeables" then
        pool[#pool + 1] = "c_ceres"
    else
        pool[#pool + 1] = "j_joker"
    end

    return pool, pool_key
end

local orig_set_edition = Card.set_edition

function Card:set_edition(edition, immediate, silent)
    if is_past_first_shop() then
        orig_set_edition(self, edition, immediate, silent)
        return
    end

    orig_set_edition(self, edition, immediate, true)

    if small(self.cost) > small(G.GAME.dollars) then
        orig_set_edition(self, nil, immediate, silent)
    elseif not silent then
        orig_set_edition(self, edition, immediate, silent)
    end
end
