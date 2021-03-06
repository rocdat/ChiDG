module eqn_joukowski_rans
#include <messenger.h>
    use type_equation_set,          only: equation_set_t
    use type_equation_builder,      only: equation_builder_t
    use type_fluid_pseudo_timestep, only: fluid_pseudo_timestep_t
    implicit none


    !>
    !!
    !!
    !!
    !--------------------------------------------------------------------------------------------
    type, public, extends(equation_builder_t) :: joukowski_rans

    contains

        procedure   :: init
        procedure   :: build

    end type joukowski_rans
    !********************************************************************************************




contains


    !>
    !!
    !!  @author Nathan A. Wukie (AFRL)
    !!  @date   8/30/2016
    !!
    !---------------------------------------------------------------------------------------------
    subroutine init(self)
        class(joukowski_rans),   intent(inout)  :: self

        call self%set_name('Joukowski RANS')

    end subroutine init
    !*********************************************************************************************



    !>
    !!
    !!  @author Nathan A. Wukie (AFRL)
    !!  @date   8/30/2016
    !!
    !!
    !---------------------------------------------------------------------------------------------
    function build(self,blueprint) result(equation_set)
        class(joukowski_rans),  intent(in)  :: self
        character(*),           intent(in)  :: blueprint

        type(equation_set_t)            :: equation_set
        type(fluid_pseudo_timestep_t)   :: fluid_pseudo_time

        !
        ! Set equation set name
        !
        call equation_set%set_name(self%get_name())
        

        !
        ! Add spatial operators
        !
        select case (trim(blueprint))


            case('default')
                call equation_set%add_operator('Euler Volume Flux')
                call equation_set%add_operator('Euler Boundary Average Flux')
                call equation_set%add_operator('Euler Roe Flux')
                call equation_set%add_operator('Euler BC Flux')
                call equation_set%add_operator('Euler Volume Cylindrical Source')

                call equation_set%add_operator('Fluid Viscous Volume Operator')
                call equation_set%add_operator('Fluid Viscous Boundary Average Operator')
                call equation_set%add_operator('Fluid Viscous BC Operator')
                call equation_set%add_operator('Fluid Viscous Volume Cylindrical Source')

                call equation_set%add_model('Ideal Gas')
                call equation_set%add_model('Constant Viscosity RANS')
                call equation_set%add_model('Stokes Hypothesis')
                call equation_set%add_model('Reynolds Analogy')



                call equation_set%add_operator('Spalart-Allmaras Source Operator')
                call equation_set%add_operator('Spalart-Allmaras LaxFriedrichs Operator')
                call equation_set%add_operator('Spalart-Allmaras Volume Advection Operator')
                call equation_set%add_operator('Spalart-Allmaras BC Advection Operator')
                call equation_set%add_operator('Spalart-Allmaras Boundary Diffusion Operator')
                call equation_set%add_operator('Spalart-Allmaras Volume Diffusion Operator')
                call equation_set%add_operator('Spalart-Allmaras BC Diffusion Operator')


                ! Add shear stress after turbulence viscosity models from SA so they are computed first
                call equation_set%add_model('Shear Stress')
                call equation_set%add_model('Temperature Gradient')


                call equation_set%add_pseudo_timestep(fluid_pseudo_time)


            case default
                call chidg_signal_one(FATAL, "build_navier_stokes: I didn't recognize the &
                                              construction parameter that was passed to build &
                                              the equation set.", blueprint)

        end select


    end function build
    !**********************************************************************************************






end module eqn_joukowski_rans
