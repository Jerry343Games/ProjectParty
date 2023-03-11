using UnityEngine;

namespace BarthaSzabolcs.IsometricAiming
{
    public class IsometricAiming : MonoBehaviour
    {
        #region Datamembers

        #region Editor Settings

        [SerializeField] private LayerMask groundMask;

        #endregion
        #region Private Fields

        private Camera mainCamera;

        #endregion

        #endregion


        #region Methods

        #region Unity Callbacks

        public GameObject arrow;

        private void Start()
        {
            // Cache the camera, Camera.main is an expensive operation.
            mainCamera = Camera.main;
           
        }

        private void Update()
        {
            //if (Input.GetKey(KeyCode.E)&&Input.GetKey(KeyCode.JoystickButton0))
            //{
            //    gameObject.GetComponent<Renderer>().enabled = true;
            //    //Instantiate()
            //    Aim();
            //    Debug.Log("press 0");

            //}
            //if (Input.GetKeyUp(KeyCode.E)&&Input.GetKeyUp(KeyCode.JoystickButton0))
            //{
            //    gameObject.GetComponent<Renderer>().enabled = false;
            //    Debug.Log(0);
            //    Debug.Log("up 0");
            //}
        }

        #endregion



        public void Aim()
        {
            var (success, position) = GetMousePosition();
            if (success)
            {
                // Calculate the direction
                var direction = position - transform.position;

                // You might want to delete this line.
                // Ignore the height difference.
                direction.y = 0;

                // Make the transform look in the direction.
                transform.forward = direction;
            }
        }

        public (bool success, Vector3 position) GetMousePosition()
        {
            var ray = mainCamera.ScreenPointToRay(Input.mousePosition);

            if (Physics.Raycast(ray, out var hitInfo, Mathf.Infinity, groundMask))
            {
                // The Raycast hit something, return with the position.
                return (success: true, position: hitInfo.point);
            }
            else
            {
                // The Raycast did not hit anything.
                return (success: false, position: Vector3.zero);
            }
        }

        #endregion
    }
}