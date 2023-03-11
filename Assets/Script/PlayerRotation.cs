using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerRotation : MonoBehaviour
{
    Vector2 movent;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    void Update()
    {
        PlayerRotate();
    }
    public void OnViewMove(InputAction.CallbackContext value1)
    {
        movent = value1.ReadValue<Vector2>();
    }

    void PlayerRotate()
    {
        //movent=PlayerMovement.moventToRotate;
        transform.LookAt(new Vector3(transform.position.x+ movent.x, transform.position.y,transform.position.z+ movent.y), Vector3.up);
        Debug.Log(new Vector3(transform.position.x + movent.x, transform.position.y, transform.position.z + movent.y));
    }
}
