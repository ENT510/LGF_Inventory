PrefixAnim = {
    ["water"] = {
        animData = { dictionary = 'mp_player_intdrink', clip = 'loop_bottle' },
        prop = {
            model = `prop_ld_flow_bottle`,
            pos = vec3(0.03, 0.03, 0.02),
            rot = vec3(0.0, 0.0, -1.5),
            bone = 18905
        },
        onUsing = function(item)
            Functions.playAnim(item)
        end
    },

    ["burger"] = {
        animData = { dictionary = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger_fp' },
        prop = { model = `prop_cs_burger_01`, pos = vector3(0.02, 0.02, -0.02), rot = vector3(0.0, 0.0, 0.0), bone = 18905 },
        onUsing = function(item)
            Functions.playAnim(item)
        end
    }
}
