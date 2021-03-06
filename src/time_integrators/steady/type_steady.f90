module type_steady
#include <messenger.h>
    use mod_kinds,                      only: rk,ik
    use mod_constants,                  only: ZERO
    use mod_spatial,                    only: update_space
    use mod_chidg_mpi,                  only: GLOBAL_MASTER

    use type_time_integrator_steady,    only: time_integrator_steady_t
    use type_system_assembler,          only: system_assembler_t

    use type_chidg_data,                only: chidg_data_t
    use type_nonlinear_solver,          only: nonlinear_solver_t
    use type_linear_solver,             only: linear_solver_t
    use type_preconditioner,            only: preconditioner_t
    use type_chidg_vector

    use mod_entropy,                    only: compute_entropy_error
    implicit none
    private



    !>  Object implementing solving a system of equations to steady-state.
    !!
    !!
    !!  @author Nathan A. Wukie
    !!  @date   4/29/2016
    !!
    !----------------------------------------------------------------------------------------
    type, extends(time_integrator_steady_t), public :: steady_t



    contains

        procedure   :: init
        procedure   :: step

    end type steady_t
    !****************************************************************************************





    !>  Object for assembling the implicit system.
    !!
    !!  @author Nathan A. Wukie
    !!  @date   2/8/2017
    !!
    !----------------------------------------------------------------------------------------
    type, extends(system_assembler_t), public :: assemble_steady_t


    contains

        procedure   :: assemble

    end type assemble_steady_t
    !****************************************************************************************






contains





    !>  Initialize the steady_t time integrator.
    !!
    !!  Main activity here, create the assembler and attach it to the time_integrator 
    !!  object so it can be passed to the nonlinear solver.
    !!
    !!  @author Nathan A. Wukie
    !!  @date   2/8/2017
    !!
    !----------------------------------------------------------------------------------------
    subroutine init(self,data)
        class(steady_t),    intent(inout)   :: self
        type(chidg_data_t), intent(in)      :: data

        integer(ik)             :: ierr
        type(assemble_steady_t) :: assemble_steady

        if (allocated(self%system)) deallocate(self%system)
        allocate(self%system, source=assemble_steady, stat=ierr)
        if (ierr /= 0) call AllocationError


    end subroutine init
    !*****************************************************************************************




    !>  Steady equation set. No time.
    !!
    !!  Solving R(Q) = 0
    !!
    !!  @author Nathan A. Wukie
    !!  @date   4/29/2016
    !!
    !!
    !------------------------------------------------------------------------------------------
    subroutine step(self,data,nonlinear_solver,linear_solver,preconditioner)
        class(steady_t),                        intent(inout)   :: self
        type(chidg_data_t),                     intent(inout)   :: data
        class(nonlinear_solver_t),  optional,   intent(inout)   :: nonlinear_solver
        class(linear_solver_t),     optional,   intent(inout)   :: linear_solver
        class(preconditioner_t),    optional,   intent(inout)   :: preconditioner


        !
        ! Simply solve the nonlinear system. No iteration in time.
        !
        call nonlinear_solver%solve(data,self%system,linear_solver,preconditioner)


        !
        ! Store end residual from nonlinear solver.
        !
        call self%residual_norm%push_back(nonlinear_solver%residual_norm%at(nonlinear_solver%residual_norm%size()))


        !call write_line("Entropy Error: ", compute_entropy_error(data), io_proc=GLOBAL_MASTER)


    end subroutine step
    !******************************************************************************************








    !>  Assemble the system for the 'Steady' equations with no time derivative contributions.
    !!
    !!  @author Nathan A. Wukie
    !!  @date   2/8/2016
    !!
    !-----------------------------------------------------------------------------------------
    subroutine assemble(self,data,timing,differentiate)
        class(assemble_steady_t),   intent(inout)               :: self
        type(chidg_data_t),         intent(inout)               :: data
        real(rk),                   intent(inout),  optional    :: timing
        logical,                    intent(in),     optional    :: differentiate


        !
        ! Steady equation, so we only need the spatial operators computed.
        !
        data%time_manager%itime = 1
        data%time_manager%t     = ZERO
        call update_space(data,timing,differentiate)


    end subroutine assemble
    !******************************************************************************************



    
end module type_steady
