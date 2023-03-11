using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
//using UnityEditor;
using UnityEngine.UI;

public class PlayerMovement : MonoBehaviour
{
    [Header("Player Move")]
    public float moveSpeed;
    Vector2 movent;

    [Header("Control Model Rotate")]
    public GameObject playerModel;
    private Transform modelPos;

    [Header("Aiming & Shooting")]
    public GameObject aimingArrow;
    public LayerMask groundMask;
    public GameObject bulletPrefab;
    Vector2 rotate;
    Vector2 mousePosition;
    private float aimKeyValue=0f;
    bool hasHold=false;

    [Header("CreatRope")]
    private float ropeKeyValue = 0f;
    public GameObject circle;
    //测试正方体
    //public GameObject testCube;

    [Header("InputSystem")]
    PlayerInput playerInput;
    public Material[] modelMat;
    public Material[] arrowMat;
    public Material[] circleMat;
    public Transform[] resetPoints;
    int playerNum;

    [Header("CreatRop")]
    bool hasFind;
    bool ropeCreated;
    bool creatButtonPress;
    GameObject rope01;
    GameObject rope02;
    GameObject rope12;





    // Start is called before the first frame update
    void Start()
    {
        hasFind = false;
        ropeCreated = false;
        creatButtonPress = false;
    }

    private void Awake()
    {
        playerInput = GetComponent<PlayerInput>();
        playerNum = playerInput.playerIndex;
        if (playerNum == 0)
        {
            gameObject.name = "Player 0";
            playerModel.GetComponent<MeshRenderer>().material=modelMat[0];
            aimingArrow.GetComponent<MeshRenderer>().material = arrowMat[0];
            circle.GetComponent<MeshRenderer>().material = circleMat[0];
            transform.position = resetPoints[0].position;
        }
        if (playerNum == 1)
        {
            gameObject.name = "Player 1";
            playerModel.GetComponent<MeshRenderer>().material = modelMat[1];
            aimingArrow.GetComponent<MeshRenderer>().material = arrowMat[1];
            circle.GetComponent<MeshRenderer>().material = circleMat[1];
            transform.position = resetPoints[1].position;
        }
        if (playerNum == 2)
        {
            gameObject.name = "Player 2";
            playerModel.GetComponent<MeshRenderer>().material = modelMat[2];
            aimingArrow.GetComponent<MeshRenderer>().material = arrowMat[2];
            circle.GetComponent<MeshRenderer>().material = circleMat[2];
            transform.position = resetPoints[2].position;
        }
        if (playerNum == 3)
        {
            gameObject.name = "Player 3";
            playerModel.GetComponent<MeshRenderer>().material = modelMat[3];
            aimingArrow.GetComponent<MeshRenderer>().material = arrowMat[3];
            circle.GetComponent<MeshRenderer>().material = circleMat[3];
            transform.position = resetPoints[3].position;
        }
    }

    // Update is called once per frame
    void Update()
    {
        FindRope();
        if (PlayerIndentify.isStartGame)
        {
            PlayerMove();
            Aiming();
            LinkRope();
        }
        
    }


    //监听双设备移动输入
    public void OnMove(InputAction.CallbackContext value0)
    {
        movent = value0.ReadValue<Vector2>();
    }
    //监听手柄旋转瞄准输入
    public void OnRotate(InputAction.CallbackContext value)
    {
        rotate = value.ReadValue<Vector2>();
    }
    //监听鼠标瞄准输入
    public void OnMouseRotate(InputAction.CallbackContext value)
    {
        mousePosition = value.ReadValue<Vector2>();
        //Debug.Log("Mouse Position" + mousePosition);
    }
    //监听手柄瞄准键
    public void OnAim(InputAction.CallbackContext value)
    {
        //getShoulderDown = value.ReadValue<bool>();
        aimKeyValue = value.ReadValue<float>();
        
    }
    //监测链接键输入
    public void OnCreatRope(InputAction.CallbackContext value)
    {
        ropeKeyValue = value.ReadValue<float>();
        //Debug.Log("!!!!!!!!!!!!!!!!!!!!!");
    }


    //双设备移动
    private void PlayerMove()
    {
        transform.Translate(new Vector3(movent.x, 0f, movent.y) * Time.deltaTime * moveSpeed);
        playerModel.transform.LookAt(new Vector3(playerModel.transform.position.x + movent.x, playerModel.transform.position.y, playerModel.transform.position.z + movent.y), Vector3.up);
    }

    //手柄瞄准
    private void Aiming()
    {
        if (aimKeyValue == 1f)
        {
            aimingArrow.SetActive(true);
            MouseAming();
            aimingArrow.transform.LookAt(new Vector3(aimingArrow.transform.position.x + rotate.x, aimingArrow.transform.position.y, aimingArrow.transform.position.z + rotate.y), Vector3.up);
            hasHold = true;        
        }
        if(aimKeyValue==0f&&hasHold)
        {
            hasHold = false;
            Debug.Log("Fire");
            Instantiate(bulletPrefab, aimingArrow.transform.position, aimingArrow.transform.rotation);
            aimingArrow.SetActive(false);
        }
    }

    //创建绳子
    private void LinkRope()
    {
        if (PlayerIndentify.staticTotalNum == 3)//3玩家
        {
            if (ropeKeyValue == 1 && !ropeCreated && !creatButtonPress)
            {
                if (PlayerIndentify.link0_1 && (playerNum == 0 || playerNum == 1))
                {
                    rope01.SetActive(true);
                }
                if (PlayerIndentify.link0_2 && (playerNum == 0 || playerNum == 2))
                {
                    rope02.SetActive(true);
                }
                if (PlayerIndentify.link1_2 && (playerNum == 1 || playerNum == 2))
                {
                    rope12.SetActive(true);
                }
                ropeCreated = true;
                creatButtonPress = true;
            }
            if (ropeKeyValue == 0 && creatButtonPress)
            {
                creatButtonPress = false;
            }

            if (ropeCreated && !creatButtonPress && ropeKeyValue == 1)
            {
                Debug.Log("Release");
                if ((playerNum == 0 || playerNum == 1))
                {
                    rope01.SetActive(false);
                }
                if ((playerNum == 0 || playerNum == 2))
                {
                    rope02.SetActive(false);
                }
                if ((playerNum == 1 || playerNum == 2))
                {
                    rope12.SetActive(false);
                }
                creatButtonPress = true;
                ropeCreated = false;
            }
        }
        if (PlayerIndentify.staticTotalNum == 2)//2玩家
        {
            if (ropeKeyValue == 1 && !ropeCreated && !creatButtonPress)
            {
                if (PlayerIndentify.link0_1 && (playerNum == 0 || playerNum == 1))
                {
                    rope01.SetActive(true);
                }
                ropeCreated = true;
                creatButtonPress = true;
            }
            if (ropeKeyValue == 0 && creatButtonPress)
            {
                creatButtonPress = false;
            }
            if (ropeCreated && !creatButtonPress && ropeKeyValue == 1)
            {
                Debug.Log("Release");
                if ((playerNum == 0 || playerNum == 1))
                {
                    rope01.SetActive(false);
                }
                creatButtonPress = true;
                ropeCreated = false;
            }
        }
    }
    //寻找绳子
    private void FindRope()
    {
        if (PlayerIndentify.isStartGame && !hasFind)
        {
            if (PlayerIndentify.staticTotalNum == 3)
            {
                rope01 = FindObject2("Ropes", "Rope 0-1");
                rope02 = FindObject2("Ropes", "Rope 0-2");
                rope12 = FindObject2("Ropes", "Rope 1-2");
                hasFind = true;
            }

            if (PlayerIndentify.staticTotalNum == 2)
            {
                rope01 = FindObject2("Ropes", "Rope 0-1");
                hasFind = true;
            }

        }
    }

    //鼠标瞄准
    private void MouseAming()
    {
        var (success, position) = GetMousePosition();
        if (success)
        {
            // Calculate the direction
            var direction = position - aimingArrow.transform.position;

            // You might want to delete this line.
            // Ignore the height difference.
            direction.y = 0;

            // Make the transform look in the direction.
            aimingArrow.transform.forward = direction;
        }
    }

    //鼠标瞄准射线转换
    public (bool success, Vector3 position) GetMousePosition()
    {
        var ray = Camera.main.ScreenPointToRay(mousePosition);

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
    private static GameObject FindObject2(string parentName,string childName)
    {
        GameObject parentObj = GameObject.Find(parentName);
        GameObject bbb = parentObj.transform.Find(childName).gameObject;
        return bbb;
    }

}
