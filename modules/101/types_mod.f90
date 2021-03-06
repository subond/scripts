module types_mod

    implicit none
    public

    type :: dict
        character (len = 80) :: key, value
    end type dict

    type :: netcdf_model
        ! in degrees can make a better truncation
        real :: lat_min, lon_min, dlat, dlon  
        integer :: nlats, nlons
        type(dict), pointer :: pattrs(:)
    end type netcdf_model

    type :: netcdf_var
        character (len = 80) :: name, long_name, units
        real, pointer :: p(:,:)
    end type netcdf_var

end module types_mod
