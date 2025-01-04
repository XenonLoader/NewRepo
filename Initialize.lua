local _IJNwuyuq = function()
    local _LrYVZjmu = function(err)
        warn("\91Script Error\93: " .. tostring(err))
        return err
    end

    local _uiXIEANb = function()
        local _VZDUcESo = {
            [1] = function()
                -- Deklarasi fungsi Notify
                local _CjPZCBgjTT = function(_WmJaIptR)
                    game:GetService("\83\116\97\114\116\101\114\71\117\105"):SetCore("\83\101\110\100\78\111\116\105\102\105\99\97\116\105\111\110", {
                        Title = "\88\101\110\111\110\32\78\111\116\105\102\105\99\97\116\105\111\110",
                        Text = _WmJaIptR,
                        Duration = 10
                    })
                end

                -- Ambil nama tempat
                local _Fr_eLOUozE = game:GetService("\77\97\114\107\101\116\112\108\97\99\101\83\101\114\118\105\99\101"):GetProductInfo(game.PlaceId).Name
                if _Fr_eLOUozE:find("\93") then
                    _Fr_eLOUozE = _Fr_eLOUozE:split("\93")[2]
                end
                if _Fr_eLOUozE:find("\41") then
                    _Fr_eLOUozE = _Fr_eLOUozE:split("\41")[2]
                end

                -- Ganti karakter dalam nama tempat
                _Fr_eLOUozE = _Fr_eLOUozE:gsub("\91\94\37\97\93", "")

                -- Pemberitahuan
                _CjPZCBgjTT("\71\97\109\101\32\102\111\117\110\100\44\32\116\104\101\32\115\99\114\105\112\116\32\105\115\32\108\111\97\100\105\110\103.")
            end
        }

        -- Panggil fungsi pertama dalam tabel
        _VZDUcESo[1]()
    end

    -- Eksekusi fungsi dengan xpcall untuk menangkap error
    local success, result = xpcall(_uiXIEANb, _LrYVZjmu)

    if success then
        print("\91Script\93: \83\117\99\99\101\115\115\102\117\108\108\121\32\101\120\101\99\117\116\101\100!")
    end
end

_IJNwuyuq()
