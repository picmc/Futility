!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++!
!                          Futility Development Group                          !
!                             All rights reserved.                             !
!                                                                              !
! Futility is a jointly-maintained, open-source project between the University !
! of Michigan and Oak Ridge National Laboratory.  The copyright and license    !
! can be found in LICENSE.txt in the head directory of this repository.        !
!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++!
PROGRAM testGeom_Triangle6
#include "UnitTest.h"
USE ISO_FORTRAN_ENV
USE UnitTest
USE IntrType
USE Strings
USE Geom_Triangle6
USE Geom_Points
USE Geom_QuadraticSegment

IMPLICIT NONE

CREATE_TEST('TRIANGLE TYPE')
REGISTER_SUBTEST('CLEAR', testClear)
REGISTER_SUBTEST('INIT', testInit)
REGISTER_SUBTEST('INTERPOLATE', testInterpolate)
REGISTER_SUBTEST('DERIVATIVE', testDerivative)
REGISTER_SUBTEST('AREA', testArea)
!REGISTER_SUBTEST('POINT INSIDE', testPointInside)
!REGISTER_SUBTEST('INTERSECT LINE', testIntersectLine)
FINALIZE_TEST()
!
!===============================================================================
CONTAINS
!
!-------------------------------------------------------------------------------
SUBROUTINE testClear()
  TYPE(Triangle6_2D) :: tri
  INTEGER(SIK) :: i
  DO i=1,6
    CALL tri%points(i)%init(DIM=2, X=1.0_SRK, Y=1.0_SRK)
  ENDDO

  CALL tri%clear()
  DO i=1,6
    ASSERT(tri%points(i)%dim == 0, "Value not cleared")
    ASSERT(.NOT. ALLOCATED(tri%points(i)%coord), "Value not cleared")
  ENDDO
ENDSUBROUTINE testClear
!
!-------------------------------------------------------------------------------
SUBROUTINE testInit()
  TYPE(Triangle6_2D) :: tri
  TYPE(PointType) :: p1, p2, p3, p4, p5, p6

  CALL p1%init(DIM=2, X=0.0_SRK, Y=0.0_SRK)
  CALL p2%init(DIM=2, X=1.0_SRK, Y=0.0_SRK)
  CALL p3%init(DIM=2, X=0.0_SRK, Y=1.0_SRK)
  CALL p4%init(DIM=2, X=0.5_SRK, Y=0.0_SRK)
  CALL p5%init(DIM=2, X=0.5_SRK, Y=0.5_SRK)
  CALL p6%init(DIM=2, X=0.0_SRK, Y=0.5_SRK)
  CALL tri%set(p1, p2, p3, p4, p5, p6)
  ASSERT(tri%points(1) == p1, "Point assigned incorrectly")
  ASSERT(tri%points(2) == p2, "Point assigned incorrectly")
  ASSERT(tri%points(3) == p3, "Point assigned incorrectly")
  ASSERT(tri%points(4) == p4, "Point assigned incorrectly")
  ASSERT(tri%points(5) == p5, "Point assigned incorrectly")
  ASSERT(tri%points(6) == p6, "Point assigned incorrectly")
ENDSUBROUTINE testInit
!
!-------------------------------------------------------------------------------
SUBROUTINE testInterpolate()
  TYPE(Triangle6_2D) :: tri
  TYPE(PointType) :: p1, p2, p3, p4, p5, p6, p
  CALL p1%init(DIM=2, X=0.0_SRK, Y=0.0_SRK)
  CALL p2%init(DIM=2, X=1.0_SRK, Y=0.0_SRK)
  CALL p3%init(DIM=2, X=0.0_SRK, Y=1.0_SRK)
  CALL p4%init(DIM=2, X=0.5_SRK, Y=0.0_SRK)
  CALL p5%init(DIM=2, X=0.5_SRK, Y=0.5_SRK)
  CALL p6%init(DIM=2, X=0.0_SRK, Y=0.5_SRK)
  CALL tri%set(p1, p2, p3, p4, p5, p6)
  p = interpolate(tri, 0.0_SRK, 0.0_SRK)
  ASSERT( p == p1, "Wrong point")

  p = interpolate(tri, 1.0_SRK, 0.0_SRK)
  ASSERT( p == p2, "Wrong point")

  p = interpolate(tri, 0.0_SRK, 1.0_SRK)
  ASSERT( p == p3, "Wrong point")

  p = interpolate(tri, 0.5_SRK, 0.0_SRK)
  ASSERT( p == p4, "Wrong point")

  p = interpolate(tri, 0.5_SRK, 0.5_SRK)
  ASSERT( p == p5, "Wrong point")

  p = interpolate(tri, 0.0_SRK, 0.5_SRK)
  ASSERT( p == p6, "Wrong point")
ENDSUBROUTINE testInterpolate
!
!-------------------------------------------------------------------------------
SUBROUTINE testDerivative()
  TYPE(Triangle6_2D) :: tri
  TYPE(PointType) :: p1, p2, p3, p4, p5, p6, dr, ds, p_r, p_s
  CALL p1%init(DIM=2, X=0.0_SRK, Y=0.0_SRK)
  CALL p2%init(DIM=2, X=1.0_SRK, Y=0.0_SRK)
  CALL p3%init(DIM=2, X=0.0_SRK, Y=1.0_SRK)
  CALL p4%init(DIM=2, X=0.5_SRK, Y=0.0_SRK)
  CALL p5%init(DIM=2, X=0.5_SRK, Y=0.5_SRK)
  CALL p6%init(DIM=2, X=0.0_SRK, Y=0.5_SRK)
  CALL p_r%init(DIM=2, X=1.0_SRK, Y=0.0_SRK)
  CALL p_s%init(DIM=2, X=0.0_SRK, Y=1.0_SRK)
  CALL tri%set(p1, p2, p3, p4, p5, p6)

  CALL derivative(tri, 0.0_SRK, 0.0_SRK, dr, ds)
  ASSERT( dr .APPROXEQA. p_r, "Wrong point")
  ASSERT( ds .APPROXEQA. p_s, "Wrong point")
ENDSUBROUTINE testDerivative
!
!-------------------------------------------------------------------------------
SUBROUTINE testArea()
  TYPE(Triangle6_2D) :: tri
  TYPE(PointType) :: p1, p2, p3, p4, p5, p6
  REAL(SRK) :: a
  CALL p1%init(DIM=2, X=0.0_SRK, Y=0.0_SRK)
  CALL p2%init(DIM=2, X=1.0_SRK, Y=0.0_SRK)
  CALL p3%init(DIM=2, X=0.0_SRK, Y=1.0_SRK)
  CALL p4%init(DIM=2, X=0.5_SRK, Y=0.0_SRK)
  CALL p5%init(DIM=2, X=0.5_SRK, Y=0.5_SRK)
  CALL p6%init(DIM=2, X=0.0_SRK, Y=0.5_SRK)
  CALL tri%set(p1, p2, p3, p4, p5, p6)
  a = area(tri)
  ASSERT( SOFTEQ(a, 0.5_SRK, 1.0E-6_SRK), "Wrong area")
  CALL p1%clear()
  CALL p2%clear()
  CALL p3%clear()
  CALL p4%clear()
  CALL p5%clear()
  CALL p6%clear()
  CALL tri%clear()
  CALL p1%init(DIM=2, X=0.0_SRK, Y=0.0_SRK)
  CALL p2%init(DIM=2, X=2.0_SRK, Y=0.0_SRK)
  CALL p3%init(DIM=2, X=2.0_SRK, Y=2.0_SRK)
  CALL p4%init(DIM=2, X=1.5_SRK, Y=0.25_SRK)
  CALL p5%init(DIM=2, X=3.0_SRK, Y=1.0_SRK)
  CALL p6%init(DIM=2, X=1.0_SRK, Y=1.0_SRK)
  CALL tri%set(p1, p2, p3, p4, p5, p6)
  a = area(tri)
  ASSERT( SOFTEQ(a, 3.0_SRK, 1.0E-6_SRK), "Wrong area")
ENDSUBROUTINE testArea
!!
!!-------------------------------------------------------------------------------
!SUBROUTINE testPointInside()
!  TYPE(Triangle6_2D) :: tri
!  TYPE(PointType) :: p1, p2, p3, p
!  LOGICAL(SBK) :: bool
!
!  CALL p1%init(DIM=2, X=0.0_SRK, Y=0.0_SRK)
!  CALL p2%init(DIM=2, X=1.0_SRK, Y=0.0_SRK)
!  CALL p3%init(DIM=2, X=1.0_SRK, Y=1.0_SRK)
!  CALL tri%set(p1, p2, p3)
!
!  CALL p%init(DIM=2, X=0.5_SRK, Y=0.1_SRK)
!  bool = pointInside(tri, p)
!  CALL p%clear()
!  ASSERT( bool, "point inside")
!
!  CALL p%init(DIM=2, X=0.5_SRK, Y=0.0_SRK)
!  bool = pointInside(tri, p)
!  CALL p%clear()
!  ASSERT( bool, "point inside")
!
!  CALL p%init(DIM=2, X=0.5_SRK, Y=-0.1_SRK)
!  bool = pointInside(tri, p)
!  CALL p%clear()
!  ASSERT( .NOT. bool, "point inside")
!ENDSUBROUTINE testPointInside
!!
!!-------------------------------------------------------------------------------
!SUBROUTINE testIntersectLine()
!  TYPE(Triangle6_2D) :: tri
!  TYPE(LineType) :: l
!  TYPE(PointType) :: p1, p2, p3, p4, p5, ipoint1, ipoint2
!  INTEGER(SIK) :: npoints
!  CALL p1%init(DIM=2, X=0.0_SRK, Y=0.0_SRK)
!  CALL p2%init(DIM=2, X=1.0_SRK, Y=0.0_SRK)
!  CALL p3%init(DIM=2, X=1.0_SRK, Y=1.0_SRK)
!  CALL p4%init(DIM=2, X=2.0_SRK, Y=1.0_SRK)
!  CALL p5%init(DIM=2, X=0.0_SRK, Y=0.0_SRK)
!
!  ! 2 intersection
!  CALL tri%set(p1, p2, p3)
!  CALL l%set(p4, p5)
!  npoints = -1
!  CALL intersect(tri, l, npoints, ipoint1, ipoint2)
!  ASSERT(npoints == 2, "Intersects")
!  ASSERT(ipoint1%coord(1) .APPROXEQA. 0.0_SRK, "intersection 1")
!  ASSERT(ipoint1%coord(2) .APPROXEQA. 0.0_SRK, "intersection 1")
!  ASSERT(ipoint2%coord(1) .APPROXEQA. 1.0_SRK, "intersection 2")
!  ASSERT(ipoint2%coord(2) .APPROXEQA. 0.5_SRK, "intersection 2")
!
!  ! 1 intersection
!  CALL l%clear() 
!  CALL p4%clear()
!  CALL p5%clear()
!  CALL p4%init(DIM=2, X=-1.0_SRK, Y=1.0_SRK)
!  CALL p5%init(DIM=2, X=0.0_SRK, Y=0.0_SRK)
!  CALL l%set(p4, p5)
!  npoints = -1
!  CALL intersect(tri, l, npoints, ipoint1, ipoint2)
!  ASSERT(npoints == 1, "Intersects")
!  ASSERT(ipoint1%coord(1) .APPROXEQ. 0.0_SRK, "intersection 1")
!  ASSERT(ipoint1%coord(2) .APPROXEQ. 0.0_SRK, "intersection 1")
!
!  ! 0 intersection
!  CALL l%clear() 
!  CALL p4%clear()
!  CALL p5%clear()
!  CALL p4%init(DIM=2, X=1.0_SRK, Y=-1.0_SRK)
!  CALL p5%init(DIM=2, X=0.0_SRK, Y=-1.0_SRK)
!  CALL l%set(p4, p5)
!  npoints = -1
!  CALL intersect(tri, l, npoints, ipoint1, ipoint2)
!  ASSERT(npoints == 0, "Intersects")
!ENDSUBROUTINE testIntersectLine
ENDPROGRAM testGeom_Triangle6
