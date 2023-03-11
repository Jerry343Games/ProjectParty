using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Unity.Mathematics;
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour
{
    private CharacterController controller;
    public float moveSpeed;
    public float rotateSpeed;
    public GameObject rope;
    GameObject ropCreated;
    public Transform player1Transform;
    private Vector3 direction;
    public float speed;
    Rigidbody myRigidbody;

    Vector2 movent;
    Vector2 rotate;

    // Start is called before the first frame update
    void Start()
    {
        controller = transform.GetComponent<CharacterController>();
        myRigidbody = GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void Update()
    {
        PlayerMove();
        PlayerRotate();
    }
    
    
    public void OnMove (InputAction.CallbackContext value0)
    {
        movent = value0.ReadValue<Vector2>();
    }

    public void OnRotate(InputAction.CallbackContext value1)
    {
        rotate = value1.ReadValue<Vector2>();
        
    }

    void PlayerMove()
    {
        transform.Translate(new Vector3(movent.x, 0f, movent.y) * Time.deltaTime * moveSpeed);
        //myRigidbody.velocity = playerVelocity;
    }

    void PlayerRotate()
    {
        transform.Rotate(new Vector3(0f, rotate.x, 0f) * Time.deltaTime * rotateSpeed);
    }

    void CreatRope()
    {
        //if (Input.GetKeyDown(KeyCode.E))
        //{
            ropCreated = Instantiate(rope, new Vector3(0,0,0),Quaternion.identity);
            ropCreated.GetComponent<RopeToolkit.Rope>().spawnPoints[0] = transform.position;
            ropCreated.GetComponent<RopeToolkit.Rope>().spawnPoints[1] = player1Transform.position;
            ropCreated.SetActive(true);
            //StartCoroutine(DisplayRope());
        //}
    }

}

    //IEnumerator DisplayRope()
    //{
    //    Material myMat = GameObject.Find("Rope(Clone)").GetComponent<RopeToolkit.Rope>().material;
    //    myMat.SetFloat("ChangeAmount", Mathf.Lerp(1f,0f,Time.time * speed));
    //    yield return null;
    //}

