program binsol_to_textsol
   implicit none
   integer :: io, t, e, l
   double precision :: v, sol, se
   open(10, file='binary_final_solutions', form='unformatted', &
            status='old', iostat=io)
   if(io /= 0) stop
   open(20, file='final_solutions.txt')
   write(20,'(" trait / effect level solution               s.e.")')
   do
      read(10, iostat=io) t,e,l,sol,se
      if(io /= 0) exit
      write(20, '(2i4,i10,2f20.8)') t,e,l,sol,se
   end do
   close(10)
   close(20)
end program binsol_to_textsol
