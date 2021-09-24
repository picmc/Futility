!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++!
!                          Futility Development Group                          !
!                             All rights reserved.                             !
!                                                                              !
! Futility is a jointly-maintained, open-source project between the University !
! of Michigan and Oak Ridge National Laboratory.  The copyright and license    !
! can be found in LICENSE.txt in the head directory of this repository.        !
!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++!
PROGRAM testGeom_Quadrilateral
#include "UnitTest.h"
USE ISO_FORTRAN_ENV
USE UnitTest
USE IntrType
USE Strings
USE Geom_Quadrilateral
USE Geom_Points
USE Geom_Line

IMPLICIT NONE

CREATE_TEST('QUADRILATERAL TYPE')
REGISTER_SUBTEST('CLEAR', testClear)
REGISTER_SUBTEST('INIT', testInit)
REGISTER_SUBTEST('INTERPOLATE', testInterpolate)
REGISTER_SUBTEST('AREA', testArea)
REGISTER_SUBTEST('POINT INSIDE', testPointInside)
REGISTER_SUBTEST('INTERSECT LINE', testIntersectLine)
FINALIZE_TEST()
!
!===============================================================================
CONTAINS
!
!-------------------------------------------------------------------------------
SUBROUTINE testClear()
  TYPE(Quadrilateral_2D) :: quad
  INTEGER(SIK) :: i
  DO i=1,4
    CALL quad%points(i)%init(DIM=2, X=1.0_SRK, Y=1.0_SRK)
  ENDDO

  CALL quad%clear()
  DO i=1,4
    ASSERT(quad%points(i)%dim == 0, "Value not cleared")
    ASSERT(.NOT. ALLOCATED(quad%points(i)%coord), "Value not cleared")
  ENDDO
ENDSUBROUTINE testClear
!
!-------------------------------------------------------------------------------
SUBROUTINE testInit()
  TYPE(Quadrilateral_2D) :: quad
  TYPE(PointType) :: points(4)

  CALL points(1)%init(DIM=2, X=0.0_SRK, Y=0.0_SRK)
  CALL points(2)%init(DIM=2, X=1.0_SRK, Y=0.0_SRK)
  CALL points(3)%init(DIM=2, X=1.0_SRK, Y=1.0_SRK)
  CALL points(4)%init(DIM=2, X=0.0_SRK, Y=1.0_SRK)
  CALL quad%set(points)
  ASSERT(quad%points(1) == points(1), "Point assigned incorrectly")
  ASSERT(quad%points(2) == points(2), "Point assigned incorrectly")
  ASSERT(quad%points(3) == points(3), "Point assigned incorrectly")
  ASSERT(quad%points(4) == points(4), "Point assigned incorrectly")
ENDSUBROUTINE testInit
!
!-------------------------------------------------------------------------------
SUBROUTINE testInterpolate()
  TYPE(Quadrilateral_2D) :: quad
  TYPE(PointType) :: points(4), p

  CALL points(1)%init(DIM=2, X=0.0_SRK, Y=0.0_SRK)
  CALL points(2)%init(DIM=2, X=1.0_SRK, Y=0.0_SRK)
  CALL points(3)%init(DIM=2, X=1.0_SRK, Y=1.0_SRK)
  CALL points(4)%init(DIM=2, X=0.0_SRK, Y=1.0_SRK)
  CALL quad%set(points)
  p = interpolate(quad, 0.0_SRK, 0.0_SRK)
  ASSERT( p == points(1), "Wrong point")
  p = interpolate(quad, 1.0_SRK, 0.0_SRK)
  ASSERT( p == points(2), "Wrong point")
  p = interpolate(quad, 1.0_SRK, 1.0_SRK)
  ASSERT( p == points(3), "Wrong point")
  p = interpolate(quad, 0.0_SRK, 1.0_SRK)
  ASSERT( p == points(4), "Wrong point")
  p = interpolate(quad, 0.5_SRK, 0.5_SRK)
  ASSERT( p%coord(1) .APPROXEQA. 0.5_SRK, "Wrong point")
  ASSERT( p%coord(2) .APPROXEQA. 0.5_SRK, "Wrong point")
ENDSUBROUTINE testInterpolate
!
!-------------------------------------------------------------------------------
SUBROUTINE testArea()
  TYPE(Quadrilateral_2D) :: quad
  TYPE(PointType) :: points(4)
  REAL(SRK) :: a

  CALL points(1)%init(DIM=2, X=0.0_SRK, Y=0.0_SRK)
  CALL points(2)%init(DIM=2, X=1.0_SRK, Y=0.0_SRK)
  CALL points(3)%init(DIM=2, X=1.0_SRK, Y=1.0_SRK)
  CALL points(4)%init(DIM=2, X=0.0_SRK, Y=1.0_SRK)
  CALL quad%set(points)
  a = area(quad)
  ASSERT( a .APPROXEQA. 1.0_SRK, "Wrong area")
ENDSUBROUTINE testArea
!
!-------------------------------------------------------------------------------
SUBROUTINE testPointInside()
  TYPE(Quadrilateral_2D) :: quad
  TYPE(PointType) :: points(4), p
  LOGICAL(SBK) :: bool

  CALL points(1)%init(DIM=2, X=0.0_SRK, Y=0.0_SRK)
  CALL points(2)%init(DIM=2, X=1.0_SRK, Y=0.0_SRK)
  CALL points(3)%init(DIM=2, X=1.0_SRK, Y=1.0_SRK)
  CALL points(4)%init(DIM=2, X=0.0_SRK, Y=1.0_SRK)
  CALL quad%set(points)

  CALL p%init(DIM=2, X=0.5_SRK, Y=0.1_SRK)
  bool = pointInside(quad, p)
  CALL p%clear()
  ASSERT( bool, "point inside")

  CALL p%init(DIM=2, X=0.5_SRK, Y=0.0_SRK)
  bool = pointInside(quad, p)
  CALL p%clear()
  ASSERT( bool, "point inside")

  CALL p%init(DIM=2, X=0.5_SRK, Y=-0.1_SRK)
  bool = pointInside(quad, p)
  CALL p%clear()
  ASSERT( .NOT. bool, "point inside")
ENDSUBROUTINE testPointInside
!
!-------------------------------------------------------------------------------
SUBROUTINE testIntersectLine()
  TYPE(Quadrilateral_2D) :: quad
  TYPE(LineType) :: l
  TYPE(PointType) :: points(4), p5, p6, ipoints(2)
  INTEGER(SIK) :: npoints
  CALL points(1)%init(DIM=2, X=0.0_SRK, Y=0.0_SRK)
  CALL points(2)%init(DIM=2, X=1.0_SRK, Y=0.0_SRK)
  CALL points(3)%init(DIM=2, X=1.0_SRK, Y=1.0_SRK)
  CALL points(4)%init(DIM=2, X=0.0_SRK, Y=1.0_SRK)
  CALL p5%init(DIM=2, X=2.0_SRK, Y=1.0_SRK)
  CALL p6%init(DIM=2, X=0.0_SRK, Y=0.0_SRK)

  ! 2 intersection
  CALL quad%set(points)
  CALL l%set(points(1), points(3))
  npoints = -1
  CALL intersect(quad, l, npoints, ipoints)
  ASSERT(npoints == 2, "Intersects")
  ASSERT(ipoints(1)%coord(1) .APPROXEQA. 0.0_SRK, "intersection 1")
  ASSERT(ipoints(1)%coord(2) .APPROXEQA. 0.0_SRK, "intersection 1")
  ASSERT(ipoints(2)%coord(1) .APPROXEQA. 1.0_SRK, "intersection 2")
  ASSERT(ipoints(2)%coord(2) .APPROXEQA. 1.0_SRK, "intersection 2")

  ! 1 intersection
  CALL l%clear() 
  CALL p5%clear()
  CALL p6%clear()
  CALL p5%init(DIM=2, X=-1.0_SRK, Y=1.0_SRK)
  CALL p6%init(DIM=2, X=0.0_SRK, Y=0.0_SRK)
  CALL l%set(p5, p6)
  npoints = -1
  CALL intersect(quad, l, npoints, ipoints)
  ASSERT(npoints == 1, "Intersects")
  ASSERT(ipoints(1)%coord(1) .APPROXEQ. 0.0_SRK, "intersection 1")
  ASSERT(ipoints(1)%coord(2) .APPROXEQ. 0.0_SRK, "intersection 1")

  ! 0 intersection
  CALL l%clear() 
  CALL p5%clear()
  CALL p6%clear()
  CALL p5%init(DIM=2, X=1.0_SRK, Y=-1.0_SRK)
  CALL p6%init(DIM=2, X=0.0_SRK, Y=-1.0_SRK)
  CALL l%set(p5, p6)
  npoints = -1
  CALL intersect(quad, l, npoints, ipoints)
  ASSERT(npoints == 0, "Intersects")
ENDSUBROUTINE testIntersectLine
ENDPROGRAM testGeom_Quadrilateral
