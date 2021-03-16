!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++!
!                          Futility Development Group                          !
!                             All rights reserved.                             !
!                                                                              !
! Futility is a jointly-maintained, open-source project between the University !
! of Michigan and Oak Ridge National Laboratory.  The copyright and license    !
! can be found in LICENSE.txt in the head directory of this repository.        !
!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++!
!> @brief 
!>
!> 
!> 
!> 
!> 
!> 
!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++!
MODULE FileType_XDMF
#include "Futility_DBC.h"
USE ExceptionHandler
USE Futility_DBC
USE ISO_FORTRAN_ENV
USE IntrType
USE Strings
!USE IO_Strings
USE FileType_Base
USE FileType_XML
USE FileType_HDF5
USE VTKFiles
USE ParameterLists

IMPLICIT NONE
PRIVATE

PUBLIC :: XDMFFileType
PUBLIC :: XDMFMeshType
PUBLIC :: XDMFTopologyList
PUBLIC :: ASSIGNMENT(=)

!> The module name
CHARACTER(LEN=*),PARAMETER :: modName='FILETYPE_XDMF'

!> Exception handler for the module
TYPE(ExceptionHandlerType),SAVE :: eXDMF

!> Parameter list that holds XDMF topology names, ids, etc. 
TYPE(ParamType),SAVE :: XDMFTopologyList

TYPE :: XDMFCell
  !> The cell type id followed by the vertex ids
  INTEGER(SIK), ALLOCATABLE :: vertex_list(:)
ENDTYPE XDMFCell

TYPE :: XDMFCellSet
  CHARACTER(LEN=64) :: name=''
  !> The cell ids
  INTEGER(SIK), ALLOCATABLE :: cell_list(:)
ENDTYPE XDMFCellSet

TYPE :: XDMFMeshPtrArrayType
  TYPE(XDMFMeshType), POINTER :: mesh => NULL()
ENDTYPE XDMFMeshPtrArrayType

!> Mesh to hold XDMF Data
TYPE :: XDMFMeshType
  !> The name of the set
  TYPE(StringType) :: name
  !> Looks like:
  !> x1, x2, x3, ..., xn
  !> y1, y2, y3, ..., yn
  !> z1, z2, z3, ..., zn
  !> Therefore vertices will be of shape (3, N)
  REAL(SDK), ALLOCATABLE :: vertices(:, :)
  TYPE(XDMFCell), ALLOCATABLE :: cells(:)
  TYPE(XDMFCellSet), ALLOCATABLE :: cell_sets(:)
  TYPE(XDMFMeshType), POINTER :: parent => NULL(), children(:) => NULL()
!  TYPE(XDMFMeshPtrArrayType), ALLOCATABLE :: children(:)
ENDTYPE XDMFMeshType


!> The XDMF File type
TYPE,EXTENDS(BaseFileType) :: XDMFFileType
!
!List of type bound procedures
  CONTAINS
    !> @copybrief FileType_XDMF::fopen_XDMFFileType
    !> @copydoc FileType_XDMF::fopen_XDMFFileType
    PROCEDURE,PASS :: fopen => fopen_XDMFFileType
    !> @copybrief FileType_XDMF::fclose_XDMFFileType
    !> @copydoc FileType_XDMF::fclose_XDMFFileType
    PROCEDURE,PASS :: fclose => fclose_XDMFFileType
    !> @copybrief FileType_XDMF::fdelete_XDMFFileType
    !> @copydoc FileType_XDMF::fdelete_XDMFFileType
    PROCEDURE,PASS :: fdelete => fdelete_XDMFFileType
    !> @copybrief FileType_XDMF::importFromDisk_XDMFFileType
    !> @copydoc FileType_XDMF::importFromDisk_XDMFFileType
    PROCEDURE,PASS :: importFromDisk => importFromDisk_XDMFFileType
ENDTYPE XDMFFileType


INTERFACE ASSIGNMENT(=)
  MODULE PROCEDURE assign_XDMFMeshType
ENDINTERFACE

!
!===============================================================================
CONTAINS
!
!-------------------------------------------------------------------------------
!> @brief Opens the XDMF file type for I/O
!> @param file the XDMF file type object
!>
!> @todo fix how the unit number is set
!>
SUBROUTINE fopen_XDMFFileType(file)
  CHARACTER(LEN=*),PARAMETER :: myName='fopen_XDMFFileType'
  CLASS(XDMFFileType),INTENT(INOUT) :: file
  LOGICAL(SBK) :: lopen
  INTEGER(SIK) :: funit,ierr
  TYPE(StringType) :: fname

ENDSUBROUTINE fopen_XDMFFileType
!
!-------------------------------------------------------------------------------
!> @brief Closes the XDMF file object
!> @param file the XDMF file object
!>
SUBROUTINE fclose_XDMFFileType(file)
  CHARACTER(LEN=*),PARAMETER :: myName='fclose_XDMFFileType'
  CLASS(XDMFFileType),INTENT(INOUT) :: file
  INTEGER(SIK) :: ierr
ENDSUBROUTINE fclose_XDMFFileType
!
!-------------------------------------------------------------------------------
!> @brief Deletes the XDMF file from disk
!> @param file the XDMF file object
!>
SUBROUTINE fdelete_XDMFFileType(file)
  CHARACTER(LEN=*),PARAMETER :: myName='fdelete_XDMFFileType'
  CLASS(XDMFFileType),INTENT(INOUT) :: file
  INTEGER(SIK) :: ierr
ENDSUBROUTINE fdelete_XDMFFileType
!
!-------------------------------------------------------------------------------
SUBROUTINE init_XDMFTopologyList()
  CHARACTER(LEN=*),PARAMETER :: myName='init_XDMFTopologyList'
  ! Setup param lists for cell type conversions
  ! id is XDMF topology id, 
  ! n is number of vertices,
  ! multiple names for same topology for interoperability
  CALL XDMFTopologyList%add('Topology->Triangle->id'            , 4)
  CALL XDMFTopologyList%add('Topology->Triangle->n'             , 3)
  CALL XDMFTopologyList%add('Topology->Triangle_6->id'          ,36)
  CALL XDMFTopologyList%add('Topology->Triangle_6->n'           , 6)
  CALL XDMFTopologyList%add('Topology->Tri_6->id'               ,36)
  CALL XDMFTopologyList%add('Topology->Tri_6->n'                , 6)
  CALL XDMFTopologyList%add('Topology->Quadrilateral->id'       , 5)
  CALL XDMFTopologyList%add('Topology->Quadrilateral->n'        , 4)
  CALL XDMFTopologyList%add('Topology->Quadrilateral_8->id'     ,37)
  CALL XDMFTopologyList%add('Topology->Quadrilateral_8->n'      , 8)
  CALL XDMFTopologyList%add('Topology->Quad_8->id'              ,37)
  CALL XDMFTopologyList%add('Topology->Quad_8->n'               , 8)
  
  CALL XDMFTopologyList%add('XDMFID->4' ,'Triangle'       )
  CALL XDMFTopologyList%add('XDMFID->36','Triangle_6'     )   
  CALL XDMFTopologyList%add('XDMFID->5' ,'Quadrilateral'  )   
  CALL XDMFTopologyList%add('XDMFID->37','Quadrilateral_8')
ENDSUBROUTINE init_XDMFTopologyList

!
!-------------------------------------------------------------------------------
RECURSIVE SUBROUTINE create_XDMFMesh_from_file(mesh, xmle, h5)
  CHARACTER(LEN=*),PARAMETER :: myName='create_XDMFMesh_from_file'
  TYPE(XDMFMeshType),TARGET, INTENT(INOUT)  :: mesh
  TYPE(XMLElementType), INTENT(INOUT) :: xmle
  TYPE(HDF5FileType), INTENT(INOUT) :: h5
!  TYPE(XDMFMeshType), ALLOCATABLE, TARGET  :: mesh_children(:)
  TYPE(XMLElementType), POINTER :: xmle_children(:)
  TYPE(StringType) :: strIn, strOut
  INTEGER(SIK) :: i, grid_ctr, mesh_ctr





  ! If this mesh has children
  IF(xmle%hasChildren()) THEN
    ! Determine the number or XML children that are grids
    CALL xmle%getChildren(xmle_children)
    grid_ctr = 0
    DO i=1,SIZE(xmle_children)
      IF(xmle_children(i)%name%upper() == 'GRID') grid_ctr = grid_ctr + 1
    ENDDO

    ! If some children are grids
    IF(grid_ctr > 0) THEN
      ! Allocate children for current mesh and create entities
      ALLOCATE(mesh%children(grid_ctr))
      mesh_ctr=1
      ! Create children of each grid
      DO i=1,SIZE(xmle_children)
        IF(xmle_children(i)%name%upper() == 'GRID') THEN
          strIn='Name'
          CALL xmle_children(i)%getAttributeValue(strIn,strOut)
          WRITE(*,*) ADJUSTL(strOut)
          mesh%children(mesh_ctr)%name = strOut
          mesh%children(mesh_ctr)%parent => mesh
          CALL create_XDMFMesh_from_file(mesh%children(mesh_ctr), xmle_children(i), h5)
          mesh_ctr = mesh_ctr + 1
        ENDIF
      ENDDO
    ! If this mesh does not have grid children it is a leaf on the tree.
    ! Add vertices, cells, etc.
    ELSE
      WRITE(*,*) "Lowest level. Initializing mesh attributes"
!      CALL setup_leaf_XDMFMesh_from_file(mesh, xmle, h5) 
    ENDIF
  ELSE
    CALL eXDMF%raiseError(modName//'::'//myName// &
      ' - Expected the XML element to have children.') 
  ENDIF

ENDSUBROUTINE create_XDMFMesh_from_file

!
!-------------------------------------------------------------------------------
SUBROUTINE setup_leaf_XDMFMesh_from_file(mesh, xmle, h5)
  CHARACTER(LEN=*),PARAMETER :: myName='setup_leaf_XDMFMesh_from_file'
  TYPE(XDMFMeshType),INTENT(INOUT)  :: mesh
  TYPE(XMLElementType), INTENT(INOUT) :: xmle 
  TYPE(HDF5FileType), INTENT(INOUT) :: h5
  TYPE(XMLElementType), POINTER :: xmle_children(:), ele_children(:)
  TYPE(StringType) :: elname, strIn, strOut, content, group, dtype, toponame
  TYPE(StringType),ALLOCATABLE :: strArray(:),segments(:)
  INTEGER(SLK) :: nnodes
  INTEGER(SIK) :: i,j
  INTEGER(SIK),ALLOCATABLE :: dshape(:)
  REAL(SSK),ALLOCATABLE :: vals4_2d(:,:)
  REAl(SDK),ALLOCATABLE :: vals8_2d(:,:)


  REQUIRE(xmle%hasChildren())
  CALL xmle%getChildren(xmle_children)
  DO i=1,SIZE(xmle_children)
    elname=xmle_children(i)%name%upper()
    SELECTCASE(ADJUSTL(elname))
      CASE("GEOMETRY")
        ! GeometryType
        strIn='GeometryType'
        CALL xmle_children(i)%getAttributeValue(strIn,strOut)
        IF(strOut /= 'XYZ') THEN
          CALL eXDMF%raiseWarning(modName//'::'//myName// &
            ' - GeometryType only supports XYZ right now.')
        ENDIF
        ! Format
        CALL xmle_children(i)%getChildren(ele_children)
        REQUIRE(SIZE(ele_children) == 1)
        strIn='Format'
        CALL ele_children(1)%getAttributeValue(strIn,strOut)
        IF(strOut /= 'HDF') THEN
          CALL eXDMF%raiseWarning(modName//'::'//myName// &
            ' - only supports HDF5 geometry data right now.')
        ENDIF
        ! Node Data
        strIn='Dimensions'
        CALL ele_children(1)%getAttributeValue(strIn,strOut)
        strArray=strOut%split()
        REQUIRE(strArray(2) == '3')
        nnodes=strArray(1)%stoi()
        ! This is all awful string manipulation to get the h5 group
        content=ele_children(1)%getContent()
        segments=content%split(':')
        group=segments(2)%substr(2,LEN(segments(2)))
        REQUIRE(h5%pathExists(CHAR(group)))
        group = group%replace("/", "->")
        ! Data shape
        dshape=h5%getDataShape(CHAR(group))
        REQUIRE(dshape(1) == 3)
        REQUIRE(dshape(2) == nnodes)
        ! Data type
        dtype=h5%getDataType(CHAR(group))
        IF(dtype == 'SSK') THEN
          CALL h5%fread(CHAR(group),vals4_2d)
        ELSE
          CALL h5%fread(CHAR(group),vals8_2d)
        ENDIF
        ! Problem if SSK?
        ALLOCATE(mesh%vertices(3,nnodes))
        IF(dtype == 'SSK') THEN
          mesh%vertices=vals4_2d
          DEALLOCATE(vals4_2d)
        ELSE
          mesh%vertices=vals8_2d
          DEALLOCATE(vals8_2d)
        ENDIF
      CASE("TOPOLOGY")
        ! TopologyType
        strIn='TopologyType'
        CALL xmle_children(i)%getAttributeValue(strIn,toponame)
        IF(toponame%upper() == 'MIXED') THEN
          WRITE(*,*) "Mixed"
        ELSE
          ! Single topology
          IF(.NOT.XDMFTopologyList%has(CHAR(toponame))) CALL eXDMF%raiseError(modName// &
            '::'//myName//' - Topology type '//TRIM(strOut)//' currently supported')


        ENDIF


      CASE("ATTRIBUTE")
        WRITE(*,*) "Attribute block"
      CASE("SET")
        WRITE(*,*) "Set block"
      CASE DEFAULT
        CALL eXDMF%raiseWarning(modName//'::'//myName// &
          ' - Unsupported data in XDMF file '//CHAR(elname))
    ENDSELECT
  ENDDO
ENDSUBROUTINE setup_leaf_XDMFMesh_from_file


!
!-------------------------------------------------------------------------------
SUBROUTINE importFromDisk_XDMFFileType(thisXDMFFile, strpath, mesh)
  CHARACTER(LEN=*),PARAMETER :: myName='importFromDisk_XDMFFileType'
  CLASS(XDMFFileType),INTENT(INOUT) :: thisXDMFFile
  CLASS(StringType),INTENT(IN) :: strpath
  TYPE(XDMFMeshType),INTENT(OUT)  :: mesh
  TYPE(XMLFileType) :: xml 
  TYPE(HDF5FileType) :: h5
  TYPE(XMLElementType),POINTER :: xmle, children(:)
  TYPE(StringType) :: strIn, strOut
  INTEGER(SIK) :: i
  CHARACTER(LEN=200) :: charpath

  IF(.NOT.XDMFTopologyList%has('Topology')) CALL init_XDMFTopologyList()

  !H5
  ! Note it is assumed that the h5 and xml files have the same name.
  i = LEN_TRIM(strpath)
  charpath = CHAR(strpath)
  CALL h5%init(charpath(1:i-4)//"h5",'READ')
  CALL h5%fopen()
  
  !XML
  CALL xml%importFromDisk(ADJUSTL(strpath))
  xmle => xml%root
  REQUIRE(ASSOCIATED(xmle))
  REQUIRE(xmle%name%upper() == 'XDMF')

  ! Version
  strIn='Version'
  CALL xmle%getAttributeValue(strIn,strOut)
  IF(strOut /= '3.0') THEN
    CALL eXDMF%raiseError(modName//'::'//myName// &
      ' - Currently only supports XDMF version 3.0') 
  ENDIF

  ! Domain
  CALL xmle%getChildren(children)
  REQUIRE(SIZE(children) > 0)
  REQUIRE(children(1)%name%upper() == 'DOMAIN')

  ! Information
  ! Note the assumption that material information is before any grids
  ! and that all grids are contained in one overall grid.
  CALL children(1)%getChildren(children)
  REQUIRE(SIZE(children) == 2)
  REQUIRE(children(1)%name%upper() == 'INFORMATION')
  REQUIRE(children(2)%name%upper() == 'GRID')

  ! Init root mesh
  strIn="Name"
  CALL children(2)%getAttributeValue(strIn,strOut)
  mesh%name = strOut

  ! Create grids
  CALL create_XDMFMesh_from_file(mesh, children(2), h5)

ENDSUBROUTINE importFromDisk_XDMFFileType 

SUBROUTINE assign_XDMFMeshType(thismesh, thatmesh)
  TYPE(XDMFMeshType), INTENT(INOUT) :: thismesh
  TYPE(XDMFMeshType), INTENT(IN) :: thatmesh

  thismesh%name = thatmesh%name
!  IF ALLOCATED(thatmesh%vertices) THEN
!    IF ALLOCATED(thismesh%vertices) DEALLOCATE(thismesh%vertices)
!    ALLOCATE(thismesh%vertices(3, SIZE(thatmesh%vertices, DIM=2))
!  ENDIF
!  REAL(SDK), ALLOCATABLE :: vertices(:, :)
!  TYPE(XDMFCell), ALLOCATABLE :: cells(:)
!  TYPE(XDMFCellSet), ALLOCATABLE :: cell_sets(:)
!  TYPE(XDMFMeshType), POINTER :: parent => NULL()
!  TYPE(XDMFMeshPtrArrayType), ALLOCATABLE :: children(:)

  

ENDSUBROUTINE assign_XDMFMeshType



ENDMODULE FileType_XDMF
